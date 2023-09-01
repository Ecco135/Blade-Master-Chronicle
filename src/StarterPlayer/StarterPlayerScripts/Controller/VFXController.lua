--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local DashEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("DashEvent")
local JumpEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEvent")
local jumpEffectT = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEffect")
local debris = game:GetService("Debris")
local ts = game:GetService("TweenService")
local jumpSound = jumpEffectT:WaitForChild("AirJump")

local VFXController = Knit.CreateController({
	Name = "VFXController",
})

function dashVFX(_, root, duration)
	root.Parent.Head.face.Transparency = 1
	for _, part in pairs(root.Parent:GetChildren()) do
		if part.ClassName == "Accessory" then
			part.Handle.Transparency = 1
		end
		if part:IsA("BasePart") then
			part.Transparency = part.Transparency + 1
		end
	end

	for _ = 0, duration - 0.1, 0.05 do
		print("clone part")
		for _, part in pairs(root.Parent:GetChildren()) do
			if part:IsA("BasePart") then
				local clone = part:Clone()
				clone:ClearAllChildren()
				clone.Anchored = true
				clone.CanCollide = false
				clone.Parent = game.Workspace.VFX
				--clone.Color = Color3.fromRGB(0, 0, 0)
				--clone.Material = Enum.Material.Neon
				clone.Transparency = 0.5
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

function VFXController:KnitStart()
	DashEvent.OnClientEvent:Connect(dashVFX)
	JumpEvent.OnClientEvent:Connect(jumpVFX)
end

function VFXController:KnitInit() end

return VFXController
