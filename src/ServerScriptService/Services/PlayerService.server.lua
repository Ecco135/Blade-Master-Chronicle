local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local PlayerDiedEvent = ReplicatedStorage.Event.PlayerDiedEvent

local FirstSpawn = Workspace.Lobby.Spawns:WaitForChild("FirstSpawn")

--local PhysicsConfig = require(ReplicatedStorage.Shared.Modules.PhysicsConfig)
Players.CharacterAutoLoads = false
print("Player Service Loaded")

local function onCharacterAdded(character)
	local HumanoidRootPart = character.HumanoidRootPart
	print(tostring(character) .. " has been added")
	--PhysicsConfig.createLinVel()
	local attachment = Instance.new("Attachment")
	attachment.Name = "LinearVelocityAttachment0"
	attachment.Parent = HumanoidRootPart

	local dashCD = Instance.new("BoolValue", character)
	dashCD.Name = "dashCD"
	dashCD.Value = false

	local stunt = Instance.new("BoolValue", character)
	stunt.Name = "stunt"
	stunt.Value = false

	local stuntTime = Instance.new("NumberValue", character)
	stuntTime.Name = "stuntTime"
	stuntTime.Value = 0

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

	--[[
	character.Humanoid.HealthChanged:Connect(function()
		print("damaged")
		if character.Humanoid.Health <= 0 then
			PlayerDiedEvent:Fire(character.Name)
		end
	end)
	
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	Humanoid.BreakJointsOnDeath = false

	]]

	character.Humanoid.Died:Connect(function()
		PlayerDiedEvent:Fire(character.Name)
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.RespawnLocation = FirstSpawn
	player.CharacterAdded:Connect(onCharacterAdded)
	player:LoadCharacter()
end)
