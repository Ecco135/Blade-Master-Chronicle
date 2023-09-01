local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local dashConfig = require(script.Parent.Parent.Modules.DashConfig)
local PhysicsConfig = require(script.Parent.Parent.Modules.PhysicsConfig)
local CombatConfig = require(script.Parent.Parent.Modules.CombatConfig)

local Sword = Player.Backpack:WaitForChild("Sword")

--local slashCount = 0
--local slashdebounce = false
local animationTrack = nil
local nextslashinput = false
local animationstate = false

local swordL = {}
for _, v in pairs(ReplicatedStorage.VFX.MotionAni.SwordL:GetChildren()) do
	swordL[tonumber(v.name:sub(-1))] = v
end

local swordslashT = 0.13
local swordstep = { 0, 1.7, 1.7, 1.7, 0 }

local function playAnimationFromServer(animationID)
	local animator = Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		animationTrack = Humanoid:LoadAnimation(animationID)
		animationTrack:Play()
	end
	return animationTrack
end

function comboRefresh()
	task.wait(0.6)
	if tick() - nextslashinput > 0.6 then
		CombatConfig.slashCount = 0
		Humanoid.WalkSpeed = 16
		CombatConfig.slashdebounce = false
	end
end

function SwordL(_, inputState)
	if inputState == Enum.UserInputState.Begin and CombatConfig.slashdebounce == false then
		nextslashinput = tick()
		CombatConfig.slashdebounce = true
		if CombatConfig.slashCount < 5 then
			if animationstate == true then
				animationTrack.keyframeReached:Wait()
				task.wait(0.05)
			end
			CombatConfig.slashCount = CombatConfig.slashCount + 1
		end
		print("slash count: " .. CombatConfig.slashCount)
		Sword:FindFirstChild("Handle").Trail.Enabled = true

		animationstate = true
		animationTrack = playAnimationFromServer(swordL[CombatConfig.slashCount])

		if CombatConfig.slashCount == 4 then
			Humanoid.JumpPower = 60
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		local direction = HumanoidRootPart.CFrame.LookVector
		local planeDirection = Vector2.new(direction.X, direction.Z)
		PhysicsConfig.linearVelocity.PlaneVelocity = swordstep[CombatConfig.slashCount] / swordslashT * planeDirection
		dashConfig.dashCD = true
		Humanoid.AutoRotate = false
		PhysicsConfig.linearVelocity.Enabled = true

		if CombatConfig.slashCount < 5 then
			CombatConfig.slashdebounce = false
		end
		Humanoid.WalkSpeed = 2
		task.spawn(comboRefresh)

		animationTrack.KeyframeReached:Wait()
		if Humanoid.JumpPower ~= 50 then
			Humanoid.JumpPower = 50
		end

		PhysicsConfig.linearVelocity.Enabled = false
		animationTrack:Destroy()
		HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + direction)
		Humanoid.AutoRotate = true
		dashConfig.dashCD = false
		Sword:FindFirstChild("Handle").Trail.Enabled = false

		animationstate = false
	end
end

Sword.Equipped:Connect(function()
	ContextActionService:BindAction("SwordL", SwordL, false, Enum.UserInputType.MouseButton1)
end)

Sword.Unequipped:Connect(function()
	ContextActionService:UnbindAction("SwordL")
end)
