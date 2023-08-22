local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Knit = require(ReplicatedStorage.Pakcages.Knit)

--Knit.AddController(ServerStorage.Money)
for _, v in ipairs(StarterPlayerScripts.Client:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Controller$") then --check if it is module and ending with controller
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit client started")
	end)
	:catch(warn)
