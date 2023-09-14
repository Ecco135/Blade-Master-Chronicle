local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local slashAni = ReplicatedStorage.VFX.MotionAni.SwordL.SwordL1

local CombatDamage = require(ServerScriptService.Server.Modules.CombatDamage)

local chaseDistance = 40
local stopDistance = 5

function getPlayerHeadings(NPCroot)
	local playerList = Players:GetPlayers()

	local distance = nil
	local direction = nil

	for _, player in pairs(playerList) do
		local character = player.Character
		local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart then
			--if character.HumanoidRootPart ~= nil then
			local distanceVector = (character.HumanoidRootPart.Position - NPCroot.Position)
			distance = distanceVector.Magnitude
			direction = distanceVector.Unit
			--end
		end
	end

	return distance, direction
end

RunService.Heartbeat:Connect(function()
	for _, NPC in CollectionService:GetTagged("Enemy") do
		if NPC.Parent ~= workspace then
			return
		end
		if NPC.Humanoid.Health == 0 then
			task.wait(2)
			NPC:Destroy()
			return
		end
		local sword = NPC.Sword
		local NPCroot = NPC.PrimaryPart
		local NPCHumanoid = NPC.Humanoid
		local distance, direction = getPlayerHeadings(NPCroot)
		if distance then
			if distance <= chaseDistance and distance >= stopDistance and NPC:GetAttribute("Attacking") == false then
				NPCHumanoid:Move(direction)
			else
				NPCHumanoid:Move(Vector3.new())
			end
			if distance < stopDistance and NPC:GetAttribute("Attacking") == false then
				NPC:SetAttribute("Attacking", true)
				task.wait(0.5)
				local attackPlay = NPCHumanoid:LoadAnimation(slashAni)
				attackPlay.Priority = Enum.AnimationPriority.Action2
				attackPlay:AdjustSpeed(attackPlay.Length / 15)
				attackPlay:Play()
				sword.BladeBox.CanTouch = true

				attackPlay.keyframeReached:Wait()
				sword.BladeBox.CanTouch = false
				task.wait(1)
				NPC:SetAttribute("Attacking", false)
			end
		end
	end
end)

for _, NPC in CollectionService:GetTagged("Enemy") do
	local sword = NPC.Sword
	sword.BladeBox.Touched:Connect(function(otherPart)
		CombatDamage.DamageCount(NPC, otherPart)
	end)
end
