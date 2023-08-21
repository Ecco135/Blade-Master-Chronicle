local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Pakcages.Knit)

--Knit.AddServices(ServerStorage.Money)
for _, v in ipairs(ServerStorage.Source:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Service$") then --check if it is module and ending with service
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit server started")
	end)
	:catch(warn)
