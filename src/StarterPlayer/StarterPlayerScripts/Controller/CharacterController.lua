local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Pakcages.Knit)
local UserInputService = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local Camera = game.Workspace.CurrentCamera

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local root = Character:WaitForChild("HumanoidRootPart")
local dashAni = ReplicatedStorage.VFX.MotionAni:WaitForChild("DashAnimation")
local dashPlay = Humanoid:LoadAnimation(dashAni)
dashPlay.Priority = Enum.AnimationPriority.Action3
local dashSound = ReplicatedStorage.VFX.MotionSound:WaitForChild("Dash")
local airJumpAni = ReplicatedStorage.VFX.MotionAni:WaitForChild("AirJumpAnimation")
local airJumpPlay = Humanoid:LoadAnimation(airJumpAni)
dashPlay.Priority = Enum.AnimationPriority.Action3

local DashEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("DashEvent")
local JumpEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEvent")

local CharacterController = Knit.CreateController({
	Name = "CharacterController",
})

local shiftKeyP = false
local WalkSpeed = 16
local RunSpeed = 25
local RunKey = Enum.KeyCode.LeftShift

local _tweenDuration = 0.2
local _walkFOV = 70
local _dashFOV = 95
local _runFOV = 80
local dashCDduration = 1
local dashDuration = 0.3
local dashSpeed = 50
local dashCD = false
local doubleJumpCount = 0

local attachment = Instance.new("Attachment")
attachment.Name = "DashAttachment0"
attachment.Parent = root

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { Character }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Attachment0 = attachment
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
linearVelocity.MaxForce = math.huge
linearVelocity.Enabled = false
linearVelocity.Parent = root

local function TweenCamera(FOV)
	TS:Create(
		Camera,
		TweenInfo.new(_tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ FieldOfView = FOV }
	):Play()
end

function IsDashAllowed()
	if dashCD then
		return
	end
	return true
end

function HandleCooldown()
	task.wait(dashCDduration)
	dashCD = false
end

function GetDashVelocity()
	local vectorMask = Vector3.new(1, 0, 1)
	local direction = root.AssemblyLinearVelocity * vectorMask

	if direction.Magnitude <= 0.1 then
		direction = Camera.CFrame.LookVector * vectorMask
	end

	direction = direction.Unit
	local planeDirection = Vector2.new(direction.X, direction.Z)
	local dashVelocity = planeDirection * dashSpeed
	return dashVelocity
end

function dash()
	if IsDashAllowed() then
		dashCD = true
		task.spawn(HandleCooldown)

		local dashVelocity = GetDashVelocity()

		DashEvent:FireServer(root, Vector3.new(dashVelocity.X, 0, dashVelocity.Y) * 1000, dashDuration)
		Humanoid.AutoRotate = false
		root.CFrame = CFrame.new(root.Position, Vector3.new(dashVelocity.X, 0, dashVelocity.Y) * 1000)

		linearVelocity.PlaneVelocity = dashVelocity
		linearVelocity.Enabled = true

		dashPlay:Play()
		dashPlay:AdjustSpeed(dashPlay.Length / dashDuration)
		dashSound:Play()
		TweenCamera(_dashFOV)

		task.wait(dashDuration)
		linearVelocity.Enabled = false
		Humanoid.AutoRotate = true
	end
end

local function Run(Input, GPE)
	if GPE then
		return
	end
	if Input.KeyCode ~= RunKey then
		return
	end

	if shiftKeyP == false then
		shiftKeyP = true
	end

	dash()

	if shiftKeyP then
		TweenCamera(_runFOV)
		Humanoid.WalkSpeed = RunSpeed
	end
end

local function RunEnd(Input, GPE)
	if GPE then
		return
	end
	if Input.KeyCode ~= RunKey then
		return
	end

	shiftKeyP = false
	TweenCamera(_walkFOV)
	Humanoid.WalkSpeed = WalkSpeed
end

local function airJump()
	if doubleJumpCount < 1 then
		if Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			JumpEvent:FireServer(root)
			airJumpPlay:Play()
			airJumpPlay:AdjustSpeed(airJumpPlay.Length / 0.3)
			task.spawn(function()
				doubleJumpCount = 1
			end)
		end
	end
end

function airJumpState(_oldState, newState)
	if newState == Enum.HumanoidStateType.Freefall then
		task.wait(0.2)
		ContextActionService:BindAction("airJump", airJump, false, Enum.KeyCode.Space)
	end
	if newState == Enum.HumanoidStateType.Landed then
		ContextActionService:UnbindAction("airJump")
		doubleJumpCount = 0
	end
end

function CharacterController:KnitStart()
	Humanoid.WalkSpeed = WalkSpeed
	UserInputService.InputBegan:Connect(Run)
	UserInputService.InputEnded:Connect(RunEnd)
	Humanoid.StateChanged:Connect(airJumpState)
end

function CharacterController:KnitInit()

end

return CharacterController
