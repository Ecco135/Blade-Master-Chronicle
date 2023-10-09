local rnd = Random.new()

CameraShake = {}
CameraShake.__index = CameraShake

function CameraShake.new(cam, char)
	local newCameraShake = {}
	setmetatable(newCameraShake, CameraShake)

	newCameraShake.cam = cam
	newCameraShake.char = char
	newCameraShake.trauma = 0
	newCameraShake.seed = rnd:NextNumber()
	newCameraShake.iterator = 0
	newCameraShake.falloffSpeed = 3 --1.6

	task.spawn(function()
		newCameraShake:init()
	end)

	return newCameraShake
end

function CameraShake:init()
	local started = tick()

	game:GetService("RunService").RenderStepped:Connect(function()
		if self.trauma > 0 then
			local now = tick() - started
			self.iterator += 1

			local shake = (self.trauma ^ 2)

			local noiseX = (math.noise(self.iterator, now, self.seed)) * shake
			local noiseY = (math.noise(self.iterator + 1, now, self.seed)) * shake
			local noiseZ = (math.noise(self.iterator + 2 + 1, now, self.seed)) * shake

			self.char.Humanoid.CameraOffset = Vector3.new(noiseX, noiseY, noiseZ)
			self.cam.CFrame = self.cam.CFrame * CFrame.Angles(noiseX / 50, noiseY / 50, noiseZ / 50)

			self.trauma =
				math.clamp(self.trauma - self.falloffSpeed * game:GetService("RunService").Heartbeat:Wait(), 0, 3)
		else
			self.char.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end
	end)
end

function CameraShake:setTrauma(newTrauma)
	self.iterator = 0
	self.seed = rnd:NextNumber()
	self.trauma = newTrauma
end

function CameraShake:shake(epicentre: Vector3 | number)
	local newTrauma = 0

	if typeof(epicentre) == "Vector3" then
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Exclude
		rp.FilterDescendantsInstances = { self.char, workspace:WaitForChild("EFFECTS CONTAINER") }

		local origin = self.char.HumanoidRootPart.Position

		local ray = workspace:Raycast(origin, (epicentre - origin), rp)

		if
			ray
			and ray.Instance.Parent ~= self.char
			and ray.Instance.Parent.Parent ~= self.char
			and not ray.Instance.Parent:FindFirstChild("Humanoid")
			and not ray.Instance.Parent.Parent:FindFirstChild("Humanoid")
		then
			newTrauma = math.clamp(5 / (origin - epicentre).Magnitude, 0, 2)
		else
			newTrauma = math.clamp(30 / (origin - epicentre).Magnitude, 0, 2)
		end
	else
		newTrauma = epicentre
	end

	self:setTrauma(newTrauma)
end

return CameraShake
