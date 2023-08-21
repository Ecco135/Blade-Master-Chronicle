local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Pakcages.Knit)

local MoneyController = Knit.CreateController({
	Name = "MoneyController",
})

function MoneyController:KnitStart()
	local function observeMoney(money)
		print("My Money: ", money)
	end

	local MoneyService = Knit.GetService("MoneyService")
	MoneyService:GetMoney():andThen(observeMoney):andThen(function()
		MoneyService.MoneyChanged:Connect(observeMoney)
	end)
end

function MoneyController:KnitInit()
	print("money controller initialized")
end

return MoneyController
