ArenaConfig = {}

local ArenaSpacing = 600
ArenaConfig.ArenaPos = {}

--setup arena position
for i = 1, 50, 1 do
	local positionZ = math.ceil(i / 5) * ArenaSpacing
	local positionY = 0
	local positionX = ((i - 1) % 5) * ArenaSpacing
	ArenaConfig.ArenaPos[i] = CFrame.new(positionX, positionY, positionZ)
end

ArenaConfig.ArenaInfo = {}
for i = 1, 50, 1 do
	ArenaConfig.ArenaInfo[i] = {}
	ArenaConfig.ArenaInfo[i].occupied = false
end

-- player - waves

return ArenaConfig
