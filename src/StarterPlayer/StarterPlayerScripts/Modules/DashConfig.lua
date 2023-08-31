local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = game.Workspace.CurrentCamera

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local root = Character:WaitForChild("HumanoidRootPart")

local TweenCamConfig = require(script.Parent.TweenCamConfig)

local dashAni = ReplicatedStorage.VFX.MotionAni:WaitForChild("DashAnimation")
local dashPlay = Humanoid:LoadAnimation(dashAni)
dashPlay.Priority = Enum.AnimationPriority.Action3
local dashSound = ReplicatedStorage.VFX.MotionSound:WaitForChild("Dash")

local DashConfig = {}

local dashFOV = 95
local _dashCDduration = 1
local _dashDuration = 0.3
local _dashSpeed = 50
DashConfig.dashCD = false

local DashEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("DashEvent")

local attachment = Instance.new("Attachment")
attachment.Name = "DashAttachment0"
attachment.Parent = root

local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Attachment0 = attachment
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
linearVelocity.MaxForce = math.huge
linearVelocity.Enabled = false
linearVelocity.Parent = root

local function IsDashAllowed()
	if DashConfig.dashCD then
		return
	end
	return true
end

local function HandleCooldown()
	task.wait(_dashCDduration)
	DashConfig.dashCD = false
end

local function GetDashVelocity()
	local vectorMask = Vector3.new(1, 0, 1)
	local direction = root.AssemblyLinearVelocity * vectorMask

	if direction.Magnitude <= 0.1 then
		direction = Camera.CFrame.LookVector * vectorMask
	end

	direction = direction.Unit
	local planeDirection = Vector2.new(direction.X, direction.Z)
	local dashVelocity = planeDirection * _dashSpeed
	return dashVelocity
end

function DashConfig.dash()
	if IsDashAllowed() then
		DashConfig.dashCD = true
		task.spawn(HandleCooldown)

		local dashVelocity = GetDashVelocity()

		DashEvent:FireServer(root, Vector3.new(dashVelocity.X, 0, dashVelocity.Y) * 1000, _dashDuration)
		--VFXService:dashVFX(root, Vector3.new(dashVelocity.X, 0, dashVelocity.Y) * 1000, dashDuration)
		Humanoid.AutoRotate = false
		root.CFrame = CFrame.new(root.Position, Vector3.new(dashVelocity.X, 0, dashVelocity.Y) * 1000)

		linearVelocity.PlaneVelocity = dashVelocity
		linearVelocity.Enabled = true
		dashPlay:Play()
		dashPlay:AdjustSpeed(dashPlay.Length / _dashDuration)
		dashSound:Play()
		TweenCamConfig.TweenCamera(dashFOV)

		task.wait(_dashDuration)
		linearVelocity.Enabled = false
		Humanoid.AutoRotate = true
	end
end

return DashConfig
