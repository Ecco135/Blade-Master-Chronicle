local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptServices = game:GetService("ServerScriptService")

local QuestEvent = ReplicatedStorage.Event.QuestEvent

local ArenaConfig = require(ServerScriptServices.Server.Modules.ArenaConfig)

local function prepArena(player)
	print("quest preparing")
	local QuestArena = ReplicatedStorage.Arena.QuestArena:Clone()
	QuestArena.Parent = game.Workspace.Arena
	for _, Part in pairs(QuestArena:GetDescendants()) do
		if Part ~= "PrimaryPart" then
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = QuestArena.PrimaryPart
			weldConstraint.Part1 = Part
			weldConstraint.Parent = QuestArena.PrimaryPart
			weldConstraint.Enabled = true
		end
	end

	QuestArena:PivotTo(ArenaConfig.ArenaPos[1])
	player.Character.HumanoidRootPart.CFrame = QuestArena.PlayerPortal.CFrame
end

QuestEvent.onServerEvent:Connect(function(player)
	prepArena(player)
end)
