local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--local PhysicsConfig = require(ReplicatedStorage.Shared.Modules.PhysicsConfig)

local function onCharacterAdded(character)
	local HumanoidRootPart = character.HumanoidRootPart
	print(tostring(character) .. " has been added")
	--PhysicsConfig.createLinVel()
	local attachment = Instance.new("Attachment")
	attachment.Name = "LinearVelocityAttachment0"
	attachment.Parent = HumanoidRootPart

	local LinearVelocity = Instance.new("LinearVelocity")
	LinearVelocity.Attachment0 = attachment
	LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	LinearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
	LinearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
	LinearVelocity.MaxForce = math.huge
	LinearVelocity.Enabled = false
	LinearVelocity.Parent = HumanoidRootPart

	character.ChildRemoved:Connect(function(part)
		if part.Name == "HumanoidRootPart" then
			print("player fall off")
			character.Humanoid.Health = 0
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)
