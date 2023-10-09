local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DashEvent = ReplicatedStorage.Event:WaitForChild("DashEvent")
local JumpEvent = ReplicatedStorage.Event:WaitForChild("JumpEvent")
local SwordcutEvent = ReplicatedStorage.Event:WaitForChild("SwordcutEvent")
local jumpEffectT = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEffect")
local debris = game:GetService("Debris")
local ts = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Character = player.Character
local cam = workspace.CurrentCamera

local jumpSound = jumpEffectT:WaitForChild("AirJump")

local dashConfig = require(script.Parent.Parent:WaitForChild("Modules").DashConfig)
local cameraShake = require(script.Parent.Parent.Modules.CameraShake)

local newCameraShake = cameraShake.new(cam, Character)

local stateCheckConnect

function dashVFX(_, root, duration)
	root.Parent.Head.face.Transparency = 1
	for _, part in pairs(root.Parent:GetChildren()) do
		if part.ClassName == "Accessory" then
			part.Handle.Transparency = 1
		end
		if part:IsA("BasePart") then
			part.Transparency = part.Transparency + 1
			part.CanTouch = false
		end
	end

	for _ = 0, duration - 0.1, 0.05 do
		for _, part in pairs(root.Parent:GetChildren()) do
			if part:IsA("BasePart") then
				local clone = part:Clone()
				clone:ClearAllChildren()
				clone.Anchored = true
				clone.CanCollide = false
				clone.Parent = game.Workspace.VFX
				clone.Color = Color3.fromRGB(131, 131, 131)
				clone.Material = Enum.Material.Neon
				clone.Transparency = 0.8
				debris:AddItem(clone, 0.3)
				ts:Create(clone, TweenInfo.new(0.3), { Transparency = 1 }):Play()
			end
		end
		task.wait(0.05)
	end

	root.Parent.Head.face.Transparency = 0
	for _, part in pairs(root.Parent:GetChildren()) do
		if part.ClassName == "Accessory" then
			part.Handle.Transparency = 0
		end
		if part:IsA("BasePart") then
			part.Transparency = part.Transparency - 1
			part.CanTouch = true
		end
	end
end

function jumpVFX(_, root)
	local jumpEffect = jumpEffectT:Clone()
	jumpSound:Play()
	jumpEffect.Position = root.position
	jumpEffect.Parent = game.Workspace.VFX

	game.Debris:AddItem(jumpEffect, 0.15)
end

function DamageVFX(Char, otherPart, hitForce)
	Char.stunt.Value = true
	Char.Sword.BladeBox.CanTouch = false
	Char.Humanoid.WalkSpeed = 0
	local DamageAni = Char.MotionAni:WaitForChild("DamageAnimation")
	local damagePlay = Char.Humanoid.Animator:LoadAnimation(DamageAni)
	damagePlay.Priority = Enum.AnimationPriority.Action4
	damagePlay:Play()
	local plr = Players:GetPlayerFromCharacter(Char)

	if plr == player then
		newCameraShake:shake(1)
	end

	if Char.stuntTime.Value == 0 then
		Char.stuntTime.Value = tick()

		task.spawn(function()
			while tick() - Char.stuntTime.Value < 1 do
				task.wait(0.1)
			end
			Char.stuntTime.Value = 0
			Char.stunt.Value = false
			Char.Humanoid.WalkSpeed = dashConfig.WalkSpeed
			damagePlay:Stop()
		end)
	else
		Char.stuntTime.Value = tick()
	end

	Char.HumanoidRootPart:ApplyImpulse(hitForce)
	local position = otherPart.Position
	local hitEffect = ReplicatedStorage.VFX.MotionEffect.HitEffect:Clone()
	hitEffect.Position = position
	hitEffect.Parent = Workspace.VFX
	hitEffect.Attachment.ParticleEmitter:Emit(1)
	game.Debris:AddItem(hitEffect, 0.3)
	--damagePlay.Stopped:Wait()
end

DashEvent.OnClientEvent:Connect(dashVFX)
JumpEvent.OnClientEvent:Connect(jumpVFX)
SwordcutEvent.OnClientEvent:Connect(DamageVFX)
