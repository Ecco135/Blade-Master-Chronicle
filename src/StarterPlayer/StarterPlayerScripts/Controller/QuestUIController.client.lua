local ReplicatedStorage = game:GetService("ReplicatedStorage")
local proximityPrompt = game.Workspace.NPC.QuestAgent.ProximityPrompt
local player = game.Players.LocalPlayer
local QuestUI = player.PlayerGui:WaitForChild("QuestUI")
local PageFrame = QuestUI.BaseFrame.PageFrame
local UIPageLayout = PageFrame.UIPageLayout

local QuestEvent = ReplicatedStorage.Event.QuestEvent

local function openQuestUI()
	print("Quest Menu Open")
	QuestUI.Enabled = true
	QuestUI.BaseFrame:TweenPosition(
		UDim2.new(0.5, 0, 0.5, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quint,
		0.5,
		true
	)
	UIPageLayout:JumpTo(PageFrame.MainPage)
end

local function closeQuestUI()
	local function QuestUIDisable()
		QuestUI.Enabled = false
	end
	QuestUI.BaseFrame:TweenPosition(
		UDim2.new(0.5, 0, 1.7, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quint,
		0.5,
		true,
		QuestUIDisable
	)
end

local function openMainPage()
	UIPageLayout:JumpTo(PageFrame.MainPage)
end

PageFrame.MainPage.RampageRushBut.MouseButton1Up:Connect(function()
	UIPageLayout:JumpTo(PageFrame.RampageRushPage)
end)
PageFrame.MainPage.TutorialBut.MouseButton1Up:Connect(function()
	UIPageLayout:JumpTo(PageFrame.TutorialPage)
end)
PageFrame.TutorialPage.BackBut.MouseButton1Up:Connect(openMainPage)
PageFrame.RampageRushPage.BackBut.MouseButton1Up:Connect(openMainPage)
PageFrame.RampageRushPage.JoinBut.MouseButton1Up:Connect(function()
	QuestEvent:FireServer()
	closeQuestUI()
end)
QuestUI.BaseFrame.CloseMenuBut.MouseButton1Up:Connect(closeQuestUI)
proximityPrompt.Triggered:Connect(openQuestUI)

--Menu Open position: {0.5, 0},{0.5, 0}
