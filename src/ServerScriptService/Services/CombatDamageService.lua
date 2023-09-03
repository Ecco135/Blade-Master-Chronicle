local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwordcutEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("SwordcutEvent")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CombatDamageService = Knit.CreateService({
	Name = "CombatDamageService",
	Client = {},
})

function CombatDamageService:DamageCount(Player, otherPart)
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
		Hum:TakeDamage(10)
		task.wait(0.3)
		Hum.Parent:SetAttribute("JustCut", false)
	end
end

function CombatDamageService.Client:DamageCount(Player, otherPart)
	return self.Server:DamageCount(Player, otherPart)
end

function CombatDamageService:KnitInit() end

function CombatDamageService:KnitStart()
	self:DamageCount()
end

return CombatDamageService
