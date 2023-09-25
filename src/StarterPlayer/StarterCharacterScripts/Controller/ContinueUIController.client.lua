local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local ContinueUI = player.PlayerGui.ContinueUI
local YesBut = ContinueUI.Frame.YesBut
local NoBut = ContinueUI.Frame.NoBut

local ContinueEvent = ReplicatedStorage.Event.ContinueEvent
local EndQuestEvent = ReplicatedStorage.Event.EndQuestEvent

YesBut.MouseButton1Up:Connect(function()
	ContinueEvent:FireServer()
	ContinueUI.Enabled = false
end)

NoBut.MouseButton1Up:Connect(function()
	EndQuestEvent:FireServer()
	ContinueUI.Enabled = false
end)
