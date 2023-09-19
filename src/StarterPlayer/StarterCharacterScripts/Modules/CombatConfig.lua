local player = game.Players.LocalPlayer
local Character = player.Character
local Humanoid = Character.Humanoid

local CombatConfig = {}

CombatConfig.slashCount = 0
CombatConfig.slashdebounce = false

CombatConfig.swordL = {}
for _, v in pairs(Character.MotionAni.SwordL:GetChildren()) do
	CombatConfig.swordL[tonumber(v.name:sub(-1))] = v
end

local animationTrack = nil
local swordslashT = 0.13
local swordstep = { 0, 1.7, 1.7, 1.7, 0 }

function CombatConfig.playAnimationFromServer(animationID)
	local animator = Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		animationTrack = Humanoid:LoadAnimation(animationID)
		animationTrack.Priority = Enum.AnimationPriority.Action2
		animationTrack:Play()
	end
	return animationTrack
end

return CombatConfig
