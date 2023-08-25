local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)

local Sword = Component.new({
	Tag = "Sword",
})

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local dashAni = ReplicatedStorage.VFX.MotionAni:WaitForChild("DashAnimation")
local dashPlay = Humanoid:LoadAnimation(dashAni)
dashPlay.Priority = Enum.AnimationPriority.Action3
local slashCount = 0
local slashdebounce = false
local animationTrack
local stopCount = 0

local swordL = {
	"rbxassetid://14559104190",
	"rbxassetid://14559111016",
	"rbxassetid://14559198134",
	"rbxassetid://14559264507",
	"rbxassetid://14559350913",
}
local animation = Instance.new("Animation")
local function playAnimationFromServer(animationID)
	animation.AnimationId = animationID
	local animator = Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in pairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
		animationTrack = animator:LoadAnimation(animation)
		--animationTrack:AdjustSpeed(animationTrack.Length / 0.4)
		animationTrack:Play()
	end
	return animationTrack
end

function SwordLight(_, inputState)
	if inputState == Enum.UserInputState.Begin and slashdebounce == false then
		slashdebounce = true
		if slashCount < 5 then
			slashCount = slashCount + 1
			print("slash count" .. slashCount)
			stopCount = stopCount + 1
		end
		print("Sword Slash " .. slashCount)
		animationTrack = playAnimationFromServer(swordL[slashCount])
		Humanoid.WalkSpeed = 2
		animationTrack.KeyframeReached:Wait()

		if slashCount < 5 then
			slashdebounce = false
		end

		animationTrack.Ended:Connect(function()
			print("animation ended")
			stopCount = stopCount - 1
			if stopCount == 0 then
				print("stopped based")
				slashCount = 0
				print("slash count" .. slashCount)
				Humanoid.WalkSpeed = 16
				slashdebounce = false
			end
		end)
	end
end

function Sword:_equipped()
	self.Instance.Equipped:Connect(function()
		if Player.Name == self.Instance.Parent.Name then
			ContextActionService:BindAction("SwordL1", SwordLight, false, Enum.UserInputType.MouseButton1)
		end
	end)
end

function Sword:Start()
	self:_equipped()
	print("Sword component has started")
end

return Sword
