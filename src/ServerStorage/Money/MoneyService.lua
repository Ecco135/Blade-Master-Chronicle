local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Pakcages.Knit)

local MoneyService = Knit.CreateService({
	Name = "MoneyService",
	Client = {
		MoneyChanged = Knit.CreateSignal(),
	},
	_MoneyPerPlayer = {},
	_StartingMoney = 10,
})

function MoneyService.Client:GetMoney(player)
	return self.Server:GetMoney(player)
end

function MoneyService:GetMoney(player)
	local money = self._MoneyPerPlayer[player] or self._StartingMoney
	return money
end

function MoneyService:AddMoney(player, amount)
	local currentmoney = self:GetMoney(player)
	if amount > 0 then
		local newMoney = currentmoney + amount
		self._MoneyPerPlayer[player] = newMoney
		self.Client.MoneyChanged:Fire(player, newMoney)
	end
end

function MoneyService:KnitStart()
	print("MoneyService started")

	while true do
		task.wait(1)
		for _, v in ipairs(Players:GetPlayers()) do
			self:AddMoney(v, math.random(1, 10))
		end
	end
end

function MoneyService:KnitInit()
	print("MoneyService initialized")
	Players.PlayerRemoving:Connect(function(player)
		self._MoneyPerPlayer[player] = nil
	end)
end

return MoneyService
