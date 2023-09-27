local player = game.Players.LocalPlayer
local Humanoid = player.Character.Humanoid

local MovementConfig = {}

function MovementConfig.IsWalking()
	if Humanoid.MoveDirection.Magnitude > 0 then
		return true
	else
		return false
	end
end

return MovementConfig
