local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwordcutEvent = ReplicatedStorage.Event:WaitForChild("SwordcutEvent")
local CombatDamage = {}
local hitForceUnit = 2200

function CombatDamage.DamageCount(Char, otherPart)
	if Char:GetAttribute("Enemy") then
		if otherPart.Parent:GetAttribute("Enemy") then
			return
		end
	end

	if Char:IsA("Player") then
		Char = Char.Character
	end

	if Char.Humanoid.Health <= 0 or Char.stunt.Value == true then
		return
	end

	local Hum = nil
	if otherPart.Parent then
		Hum = otherPart.Parent:FindFirstChild("Humanoid")
	end

	if Hum then
		if Hum.Parent == Char or Hum.Parent:GetAttribute("JustCut") then
			return
		end

		local hitDirection = 0
		local otherRoot = Hum.Parent.HumanoidRootPart
		local root = Char.HumanoidRootPart
		hitDirection = otherRoot.position - root.position
		local hitForce = hitDirection.unit * hitForceUnit
		Hum.Parent:SetAttribute("JustCut", true)
		Hum:TakeDamage(30)
		if Hum.Health > 0 then
			SwordcutEvent:FireAllClients(Hum.Parent, otherPart, hitForce)
		end

		task.wait(0.2)
		if Hum.Parent then
			Hum.Parent:SetAttribute("JustCut", false)
		end
	end
end

return CombatDamage
