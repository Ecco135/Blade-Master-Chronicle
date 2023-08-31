local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local dashConfig = require(script.Parent.Parent.Modules.DashConfig)

local Sword = Player.Backpack:WaitForChild("Sword")

local slashCount = 0
local slashdebounce = false
local animationTrack = nil
local nextslashinput = false
local animationstate = false

local attachment = Instance.new("Attachment")
attachment.Name = "SwordMovementAttachment0"
attachment.Parent = HumanoidRootPart

local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Attachment0 = attachment
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
linearVelocity.MaxForce = math.huge
linearVelocity.Enabled = false
linearVelocity.Parent = HumanoidRootPart

local swordL = {}
for _, v in pairs(ReplicatedStorage.VFX.MotionAni.SwordL:GetChildren()) do
	swordL[tonumber(v.name:sub(-1))] = v
end

local swordslashT = 0.13
local swordstep = { 0, 1.7, 1.7, 1.7, 0 }

local function playAnimationFromServer(animationID)
	local animator = Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in pairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
		animationTrack = animator:LoadAnimation(animationID)
		animationTrack:Play()
	end
	return animationTrack
end

function comboRefresh()
	task.wait(0.6)
	if tick() - nextslashinput > 0.6 then
		slashCount = 0
		Humanoid.WalkSpeed = 16
		slashdebounce = false
	end
end

function SwordL(_, inputState)
	if inputState == Enum.UserInputState.Begin and slashdebounce == false then
		nextslashinput = tick()
		slashdebounce = true
		if slashCount < 5 then
			if animationstate == true then
				animationTrack.keyframeReached:Wait()
				task.wait(0.05)
			end
			slashCount = slashCount + 1
		end
		print("slash count: " .. slashCount)
		Sword:FindFirstChild("Handle").Trail.Enabled = true

		animationstate = true
		animationTrack = playAnimationFromServer(swordL[slashCount])

		if slashCount == 4 then
			Humanoid.JumpPower = 60
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		local direction = HumanoidRootPart.CFrame.LookVector
		local planeDirection = Vector2.new(direction.X, direction.Z)
		linearVelocity.PlaneVelocity = swordstep[slashCount] / swordslashT * planeDirection
		dashConfig.dashCD = true
		Humanoid.AutoRotate = false
		linearVelocity.Enabled = true

		if slashCount < 5 then
			slashdebounce = false
		end
		Humanoid.WalkSpeed = 2
		task.spawn(comboRefresh)

		animationTrack.KeyframeReached:Wait()
		if Humanoid.JumpPower ~= 50 then
			Humanoid.JumpPower = 50
		end

		linearVelocity.Enabled = false
		HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + direction)
		Humanoid.AutoRotate = true
		Sword:FindFirstChild("Handle").Trail.Enabled = false
		dashConfig.dashCD = false
		animationstate = false
	end
end

Sword.Equipped:Connect(function()
	ContextActionService:BindAction("SwordL", SwordL, false, Enum.UserInputType.MouseButton1)
end)

Sword.Unequipped:Connect(function()
	ContextActionService:UnbindAction("SwordL")
end)
