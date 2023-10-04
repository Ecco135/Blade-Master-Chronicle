local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwordcutEvent = ReplicatedStorage.Event:WaitForChild("SwordcutEvent")

local CombatDamage = require(script.Parent.Parent.Modules.CombatDamage)

SwordcutEvent.OnServerEvent:Connect(CombatDamage.DamageCount)
