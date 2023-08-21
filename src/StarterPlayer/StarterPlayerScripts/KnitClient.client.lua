local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Pakcages.Knit)

--Knit.AddController(ServerStorage.Money)
for _, v in ipairs(ReplicatedStorage.Shared:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Controller$") then --check if it is module and ending with controller
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit client started")
	end)
	:catch(warn)
