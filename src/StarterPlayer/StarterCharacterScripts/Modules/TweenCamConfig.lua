local TweenService = game:GetService("TweenService")
local Camera = game.Workspace.CurrentCamera

local _tweenDuration = 0.2

local TweenCamConfig = {}

function TweenCamConfig.TweenCamera(FOV)
	TweenService:Create(
		Camera,
		TweenInfo.new(_tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ FieldOfView = FOV }
	):Play()
end

return TweenCamConfig
