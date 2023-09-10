local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DashEvent = ReplicatedStorage.Event:WaitForChild("DashEvent")
local JumpEvent = ReplicatedStorage.Event:WaitForChild("JumpEvent")

function dashVFX(player, root, dashDuration)
	DashEvent:FireAllClients(player, root, dashDuration)
end

function jumpVFX(player, root)
	JumpEvent:FireAllClients(player, root)
end

DashEvent.OnServerEvent:Connect(dashVFX)
JumpEvent.OnServerEvent:Connect(jumpVFX)
