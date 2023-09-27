local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptServices = game:GetService("ServerScriptService")

local QuestEvent = ReplicatedStorage.Event.QuestEvent
local WaveInitEvent = ReplicatedStorage.Event.WaveInitEvent
local WaveClearEvent = ReplicatedStorage.Event.WaveClearEvent
local msgPrompEvent = ReplicatedStorage.Event.MSGPromp
local PlayerDiedEvent = ReplicatedStorage.Event.PlayerDiedEvent
local ContinueEvent = ReplicatedStorage.Event.ContinueEvent
local EndQuestEvent = ReplicatedStorage.Event.EndQuestEvent

local ArenaConfig = require(ServerScriptServices.Server.Modules.ArenaConfig)

local function continue(player)
	for i, arena in pairs(ArenaConfig.ArenaInfo) do
		if arena.player == player then
			arena.alive = true
			break
		end
	end
	player:LoadCharacter()
	task.wait(0.1)
	local Sword = ReplicatedStorage.Weapon.Sword:Clone()
	Sword.Parent = player.Character
end

local function prepArena(player)
	local QuestArena = ReplicatedStorage.Arena.QuestArena:Clone()
	QuestArena.Parent = game.Workspace.Arena
	for i = 1, 50, 1 do
		if ArenaConfig.ArenaInfo[i].occupied == false then
			ArenaConfig.ArenaInfo[i].occupied = true
			ArenaConfig.ArenaInfo[i].arena = QuestArena
			ArenaConfig.ArenaInfo[i].player = player
			ArenaConfig.ArenaInfo[i].wave = 1
			ArenaConfig.ArenaInfo[i].wavegen = true
			ArenaConfig.ArenaInfo[i].eCount = 0
			ArenaConfig.ArenaInfo[i].alive = true
			ArenaConfig.ArenaInfo[i].waveclear = false
			QuestArena:PivotTo(ArenaConfig.ArenaPos[i])
			local SpawnMarker = QuestArena.SpawnMarker
			ArenaConfig.ArenaInfo[i].sMaxX = math.max(
				SpawnMarker.A.Position.X,
				SpawnMarker.B.Position.X,
				SpawnMarker.C.Position.X,
				SpawnMarker.D.Position.X
			) - 50
			ArenaConfig.ArenaInfo[i].sMinX = math.min(
				SpawnMarker.A.Position.X,
				SpawnMarker.B.Position.X,
				SpawnMarker.C.Position.X,
				SpawnMarker.D.Position.X
			) + 50
			ArenaConfig.ArenaInfo[i].sMaxZ = math.max(
				SpawnMarker.A.Position.Z,
				SpawnMarker.B.Position.Z,
				SpawnMarker.C.Position.Z,
				SpawnMarker.D.Position.Z
			) - 50
			ArenaConfig.ArenaInfo[i].sMinZ = math.min(
				SpawnMarker.A.Position.Z,
				SpawnMarker.B.Position.Z,
				SpawnMarker.C.Position.Z,
				SpawnMarker.D.Position.Z
			) + 50
			ArenaConfig.ArenaInfo[i].sY = math.max(
				SpawnMarker.A.Position.Y,
				SpawnMarker.B.Position.Y,
				SpawnMarker.C.Position.Y,
				SpawnMarker.D.Position.Y
			)
			QuestArena:SetAttribute("ArenaNo", i)
			break
		end
	end
	player.Character.HumanoidRootPart.CFrame = QuestArena.PlayerPortal.CFrame
	player.RespawnLocation = QuestArena.SpawnLocation
	local Sword = ReplicatedStorage.Weapon.Sword:Clone()
	Sword.Parent = player.Character
	QuestEvent:FireClient(player)
	msgPrompEvent:FireClient(player, "Warming Up", 2)
	task.wait(3)
	WaveInitEvent:Fire(player)
end

WaveClearEvent.Event:Connect(function(player)
	for i, arena in pairs(ArenaConfig.ArenaInfo) do
		if arena.player == player and arena.alive == true then
			arena.wave += 1
			msgPrompEvent:FireClient(player, "Wave Cleared", 2)
			task.wait(5)
			arena.waveclear = false
			WaveInitEvent:Fire(player)
		end
	end
end)

QuestEvent.onServerEvent:Connect(prepArena)

PlayerDiedEvent.Event:Connect(function(playerName)
	for i, arena in pairs(ArenaConfig.ArenaInfo) do
		if arena.player.Name == playerName then
			print("Player " .. playerName .. " has died")
			arena.alive = false
			arena.player.PlayerGui.ContinueUI.Enabled = true
			arena.player.Character.Sword:Destroy()
			break
		end
	end
end)

EndQuestEvent.onServerEvent:Connect(function(player)
	for i, arena in pairs(ArenaConfig.ArenaInfo) do
		if arena.player == player then
			print("Player " .. tostring(player) .. " end quest")
			player.RespawnLocation = game.Workspace.Lobby.Spawns.FirstSpawn
			player:LoadCharacter()
			task.wait(1)
			arena.arena:Destroy()
			task.wait(1)
			ArenaConfig.ArenaInfo[i] = {}
			ArenaConfig.ArenaInfo[i].occupied = false
			break
		end
	end
end)

ContinueEvent.onServerEvent:Connect(continue)
