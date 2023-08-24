local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local DashEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("DashEvent")
local JumpEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEvent")

local VFXService = Knit.CreateService({
	Name = "VFXService",
	Client = {},
})

function dashVFX(player, root, direction, dashDuration)
	DashEvent:FireAllClients(player, root, direction, dashDuration)
end

function jumpVFX(player, root)
	JumpEvent:FireAllClients(player, root)
end

function VFXService:KnitStart()
	DashEvent.OnServerEvent:Connect(dashVFX)
	JumpEvent.OnServerEvent:Connect(jumpVFX)
end

function VFXService:KnitInit() end

return VFXService
