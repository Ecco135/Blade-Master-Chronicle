--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local DashEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("DashEvent")
local JumpEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEvent")
local dashEffectT = ReplicatedStorage.VFX.MotionEffect:WaitForChild("DashEffect1")
local jumpEffectT = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEffect")
local debris = game:GetService("Debris")
local ts = game:GetService("TweenService")
local jumpSound = jumpEffectT:WaitForChild("AirJump")

local VFXController = Knit.CreateController({
	Name = "VFXController",
})

function dashVFX(_, root, direction, duration)
	local dashEffect1 = dashEffectT:Clone()
	dashEffect1.CFrame = CFrame.new(root.position, root.position + direction)
	dashEffect1.Parent = game.Workspace.VFX

	--remoteEvent:FireClient(player,root)

	task.wait(0.1 * duration)
	root.Parent.Head.face.Transparency = 1
	for _, part in pairs(root.Parent:GetChildren()) do
		if part.ClassName == "Accessory" then
			part.Handle.Transparency = 1
		end
		if part:IsA("BasePart") then
			local clone = part:Clone()
			clone:ClearAllChildren()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Parent = game.Workspace.VFX
			clone.Color = Color3.fromRGB(0, 0, 0)
			clone.Material = Enum.Material.Neon
			clone.Transparency = 0.5
			debris:AddItem(clone, 0.3)
			ts:Create(clone, TweenInfo.new(0.3), { Transparency = 1 }):Play()
			part.Transparency = part.Transparency + 1
		end
	end

	task.wait(0.7 * duration)

	root.Parent.Head.face.Transparency = 0
	for _, accessory in pairs(root.Parent:GetChildren()) do
		if accessory.ClassName == "Accessory" then
			accessory.Handle.Transparency = 0
		end
	end

	for _, part in pairs(root.Parent:GetChildren()) do
		if part.ClassName == "Accessory" then
			part.Handle.Transparency = 0
		end
		if part:IsA("BasePart") then
			local clone = part:Clone()
			clone:ClearAllChildren()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Parent = game.Workspace.VFX
			clone.Color = Color3.fromRGB(0, 0, 0)
			clone.Material = Enum.Material.Neon
			clone.Transparency = 0.5
			debris:AddItem(clone, 0.3)
			ts:Create(clone, TweenInfo.new(0.3), { Transparency = 1 }):Play()
			part.Transparency = part.Transparency - 1
		end
	end

	task.wait(0.2 * duration)
	local dashEffect2 = dashEffectT:Clone()
	dashEffect2.CFrame = CFrame.new(root.position, root.position + direction)
	dashEffect2.Parent = game.Workspace.VFX

	task.wait(duration * 0.5)
	dashEffect1:Destroy()
	dashEffect2:Destroy()
end

function jumpVFX(player, root)
	local jumpEffect = jumpEffectT:Clone()
	jumpSound:Play()
	jumpEffect.Position = root.position
	jumpEffect.Parent = game.Workspace.VFX

	game.Debris:AddItem(jumpEffect, 0.15)
end

function VFXController:KnitStart()
	DashEvent.OnClientEvent:Connect(dashVFX)
	JumpEvent.OnClientEvent:Connect(jumpVFX)
end

function VFXController:KnitInit() end

return VFXController
