local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = game.Workspace.CurrentCamera

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local root = Character:WaitForChild("HumanoidRootPart")

local TweenCamConfig = require(script.Parent.TweenCamConfig)
--local PhysicsConfig = require(script.Parent.PhysicsConfig)
local CombatConfig = require(script.Parent.CombatConfig)

local dashAni = Character.MotionAni:WaitForChild("DashAnimation")
local dashPlay = Humanoid:LoadAnimation(dashAni)
dashPlay.Priority = Enum.AnimationPriority.Action3
local dashSound = ReplicatedStorage.VFX.MotionSound:WaitForChild("Dash")

local DashConfig = {}

local dashFOV = 95
local _dashCDduration = 1
local _dashDuration = 0.3
local _dashSpeed = 50
local WalkSpeed = 16
local RunSpeed = 25
DashConfig.dashCD = false
DashConfig.dashDuration = _dashDuration
DashConfig.WalkSpeed = WalkSpeed
DashConfig.RunSpeed = RunSpeed

local DashEvent = ReplicatedStorage.Event:WaitForChild("DashEvent")

local function IsDashAllowed()
	if DashConfig.dashCD or Character.stunt.value == true then
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

local function collisioncheck(other, limb)
	if
		other.parent ~= Workspace.VFX
		and (
			limb == Character.UpperTorso
			or limb == Character.Head
			or limb == Character.LeftUpperArm
			or limb == Character.RightUpperArm
			or limb == root --or limb == Character.LowerTorso

		)
	then
		CombatConfig.slashdebounce = false
		root.LinearVelocity.Enabled = false
		Humanoid.AutoRotate = true
	end
end

function DashConfig.dash()
	if IsDashAllowed() then
		DashConfig.dashCD = true
		task.spawn(HandleCooldown)

		local dashVelocity = GetDashVelocity()

		DashEvent:FireServer(root, _dashDuration)
		Humanoid.AutoRotate = false
		root.CFrame = CFrame.new(root.Position, Vector3.new(dashVelocity.X, 0, dashVelocity.Y) * 1000)
		root.LinearVelocity.PlaneVelocity = dashVelocity
		root.LinearVelocity.Enabled = true
		CombatConfig.slashCount = 0
		CombatConfig.slashdebounce = true
		dashPlay:Play()
		dashPlay:AdjustSpeed(dashPlay.Length / _dashDuration)
		dashSound:Play()
		TweenCamConfig.TweenCamera(dashFOV)

		local dashcheck = Humanoid.Touched:Connect(collisioncheck)
		task.wait(_dashDuration)
		CombatConfig.slashdebounce = false
		root.LinearVelocity.Enabled = false
		dashcheck:Disconnect()
		Humanoid.AutoRotate = true
	end
end

return DashConfig
