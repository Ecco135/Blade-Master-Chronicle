local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwordcutEvent = ReplicatedStorage.Event:WaitForChild("SwordcutEvent")
local CombatDamage = {}

function CombatDamage.DamageCount(Player, otherPart)
	local Hum = nil
	if otherPart then
		Hum = otherPart.Parent:FindFirstChild("Humanoid")
	end

	if Hum then
		if Hum.Parent == Player or Hum.Parent:GetAttribute("JustCut") then
			return
		end
		Hum.Parent:SetAttribute("JustCut", true)
		SwordcutEvent:FireAllClients(Hum.Parent)
		local DamageAni = Hum.Parent.MotionAni:WaitForChild("DamageAnimation")
		local damagePlay = Hum:LoadAnimation(DamageAni)
		damagePlay.Priority = Enum.AnimationPriority.Action4
		damagePlay:Play()
		Hum:TakeDamage(10)
		task.wait(0.2)
		if Hum.Parent then
			Hum.Parent:SetAttribute("JustCut", false)
		end
	end
end

return CombatDamage