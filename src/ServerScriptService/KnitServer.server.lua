local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)

--Knit.AddServices(ServerStorage.Money)
Knit.AddServices(script.Parent.Services)
--[[
for _, v in ipairs(ServerScriptService.Server:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Service$") then --check if it is module and ending with service
		require(v)
	end
end
]]

Knit.Start()
	:andThen(function()
		print("Knit server started")
	end)
	:catch(warn)
