local player = game.Players.LocalPlayer
local PrompUI = player.PlayerGui:WaitForChild("MSGUI")
local TextLabel = PrompUI.Frame.TextLabel
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local msgPrompEvent = ReplicatedStorage.Event.MSGPromp

local function prompMSG(msg, time)
	TextLabel.Text = msg
	if PrompUI.Enabled == false then
		PrompUI.Enabled = true
	end
	task.wait(time)
	PrompUI.Enabled = false
end

msgPrompEvent.OnClientEvent:Connect(prompMSG)
