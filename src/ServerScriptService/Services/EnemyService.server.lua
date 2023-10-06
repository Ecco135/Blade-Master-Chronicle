local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WaveInitEvent = ReplicatedStorage.Event.WaveInitEvent
local WaveClearEvent = ReplicatedStorage.Event.WaveClearEvent
local msgPrompEvent = ReplicatedStorage.Event.MSGPromp

local slashAni = ReplicatedStorage.VFX.MotionAni.SwordL.SwordL1

local CombatDamage = require(ServerScriptService.Server.Modules.CombatDamage)
local ArenaConfig = require(ServerScriptService.Server.Modules.ArenaConfig)

local chaseDistance = 100
local stopDistance = 5
local enemyMax = 50
local connection = {}

function getPlayerHeadings(NPCroot, player)
	local distance = nil
	local direction = nil
	local character = player.Character
	local distanceVector = (character.HumanoidRootPart.Position - NPCroot.Position)
	distance = distanceVector.Magnitude
	direction = distanceVector.Unit

	return distance, direction
end

WaveInitEvent.Event:Connect(function(player)
	for i, arena in pairs(ArenaConfig.ArenaInfo) do
		if arena.player == player then
			local txtMSG = "Wave " .. arena.wave .. " is coming"
			msgPrompEvent:FireClient(player, txtMSG, 2)
			local enemyCount = 10 * (1.2 ^ (arena.wave - 1))
			for j = 1, enemyCount, 1 do
				while arena.wavegen == false do
					task.wait(1)
					if arena.eCount < 50 then
						arena.wavegen = true
					end
				end

				local enemy = ReplicatedStorage.Enemy.Goblin:Clone()
				local enemyPos =
					Vector3.new(math.random(arena.sMinX, arena.sMaxX), arena.sY, math.random(arena.sMinZ, arena.sMaxZ))
				local enemyFace = arena.player.Character.HumanoidRootPart.Position
				enemy.HumanoidRootPart.CFrame = CFrame.new(enemyPos, enemyFace)
				enemy:SetAttribute("ArenaNo", 1)
				enemy.Parent = arena.arena:WaitForChild("Enemy") --game.Workspace.Enemy
				arena.eCount += 1
				task.wait(1)
				if arena.eCount == 50 then
					arena.wavegen = false
				end
			end
		end
	end
end)

local function onEnemyAdded(enemy)
	local enemyHum = enemy:WaitForChild("Humanoid")
	local sword = enemy:WaitForChild("Sword")
	connection[enemy] = sword.BladeBox.Touched:Connect(function(otherPart)
		CombatDamage.DamageCount(enemy, otherPart)
	end)
	enemyHum.Died:Connect(function()
		task.wait(2)
		enemy:Destroy()
	end)

	local idleAnimation = sword.Animation.Idle
	local idlePlay = enemyHum:LoadAnimation(idleAnimation)
	local runAnimation = sword.Animation.Run
	local runPlay = enemyHum:LoadAnimation(runAnimation)
	idlePlay:Play()

	while enemyHum.Health > 0 do
		local arenaNo = enemy:GetAttribute("ArenaNo")
		local Enemyroot = enemy.PrimaryPart
		if ArenaConfig.ArenaInfo[arenaNo].alive then
			local distance, direction = getPlayerHeadings(Enemyroot, ArenaConfig.ArenaInfo[arenaNo].player)
			if distance and enemy.stunt.Value == false then
				if
					--distance <= chaseDistance
					distance >= stopDistance and enemy:GetAttribute("Attacking") == false
				then
					if idlePlay.IsPlaying then
						idlePlay:Stop()
						runPlay:Play()
						runPlay:AdjustSpeed(0.75)
					end
					enemyHum:Move(direction)
				else
					enemyHum:Move(Vector3.new())
					if not idlePlay.IsPlaying then
						runPlay:Stop()
						idlePlay:Play()
					end
				end
				if distance < stopDistance and enemy:GetAttribute("Attacking") == false then
					enemy:SetAttribute("Attacking", true)
					task.wait(0.5)
					local attackPlay = enemyHum:LoadAnimation(slashAni)
					attackPlay.Priority = Enum.AnimationPriority.Action
					attackPlay:AdjustSpeed(attackPlay.Length / 15)
					if enemy.stunt.Value == false then
						attackPlay:Play()
						sword.BladeBox.CanTouch = true

						attackPlay.Stopped:Wait()
						sword.BladeBox.CanTouch = false
					end

					task.wait(1)
					enemy:SetAttribute("Attacking", false)
				end
			end
		end
		task.wait(0.5)
	end
end

local function onEnemyRemoved(enemy)
	local arenaNo = enemy:GetAttribute("ArenaNo")
	connection[enemy]:Disconnect()
	local arena = ArenaConfig.ArenaInfo[arenaNo]
	arena.eCount -= 1
	task.wait(3)
	print(arena.eCount)
	print(arena.waveclear)
	if arena.eCount == 0 and arena.waveclear == false then
		arena.waveclear = true
		WaveClearEvent:Fire(arena.player)
	end
end

CollectionService:GetInstanceAddedSignal("Enemy"):Connect(onEnemyAdded)
CollectionService:GetInstanceRemovedSignal("Enemy"):Connect(onEnemyRemoved)
