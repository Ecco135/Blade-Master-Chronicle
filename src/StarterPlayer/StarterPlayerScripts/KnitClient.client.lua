local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(script.Parent.Controller)

for _, v in ipairs(StarterPlayerScripts.Client.Components:GetDescendants()) do
	if v:IsA("ModuleScript") then --check if it is module and ending with controller
		require(v)
	end
end

Knit.Start({ ServicePromises = false })
	:andThen(function()
		print("Knit client started")
	end)
	:catch(warn)
