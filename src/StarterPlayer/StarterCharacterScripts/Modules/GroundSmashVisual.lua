--local events = game.ReplicatedStorage:WaitForChild("Events")
--local effectsRE = events:WaitForChild("CreateGroundSmashEffects")

--local effects = game.ReplicatedStorage:WaitForChild("Effects")
--local groundSmashEffects = effects:WaitForChild("GroundSmashAttack")
--local partEffects = groundSmashEffects:WaitForChild("Parts")
--local soundEffects = groundSmashEffects:WaitForChild("Sounds")

local ts = game:GetService("TweenService")
local rocksTI = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local rnd = Random.new()

local groundSmash = {}

--[[
function setParticleRateZero(part: BasePart)

	for _, child in pairs(part:GetChildren()) do

		if child:IsA("ParticleEmitter") then
			child.Rate = 0

		else
			setParticleRateZero(child)
		end
	end
end
]]

--[[
function particleSequence(part: BasePart)

	local attachment = part.Particles

	attachment.Core:Emit(500)
	attachment.Smoke:Emit(80)

	for i = 1,3 do

		attachment.Sparks:Emit(70)
		task.wait(0.05)
	end
end
]]

function groundSmash.createDebris(pos: Vector3, radius: number)
	local numCircles = rnd:NextInteger(3, 5)

	for h = 1, numCircles do
		local numParts = rnd:NextInteger(30, 35)

		for i = 1, numParts do
			local rock = Instance.new("Part")

			local rockSize = Vector3.new(rnd:NextNumber(1.5, 2.2), rnd:NextNumber(1, 2), rnd:NextNumber(1.4, 2))
			rockSize *= h / numCircles

			local orientation = Vector3.new(rnd:NextNumber(-60, 60), rnd:NextNumber(-60, 60), rnd:NextNumber(-60, 60))

			local rx = pos.X + rnd:NextNumber(-1, 1)
			local rz = pos.Z + rnd:NextNumber(-1, 1)
			local lookAt = Vector3.new(rx, pos.Y, rz)

			local lv = CFrame.new(pos, lookAt).LookVector

			local position = pos + (lv * radius * math.clamp(h / numCircles, 0.4, 1))

			local cf = CFrame.new(position, pos + lv + orientation)

			local rp = RaycastParams.new()
			rp.FilterDescendantsInstances = { workspace["VFX"] }
			local floorRay =
				workspace:Raycast(cf.Position + Vector3.new(0, 3, 0), position - Vector3.new(0, 100, 0), rp)

			if floorRay and floorRay.Instance.Anchored then
				local colour = floorRay.Instance.Color
				local mat = floorRay.Instance.Material

				rock.Size = Vector3.new(0, 0, 0)
				rock.Position = floorRay.Position
				rock.Orientation = orientation

				rock.CanCollide = false
				rock.Anchored = true
				rock.TopSurface = Enum.SurfaceType.Smooth
				rock.Color = colour or Color3.fromRGB(83, 86, 90)
				rock.Material = mat or Enum.Material.Slate

				rock.Parent = workspace["VFX"]

				local rockTween = ts:Create(rock, rocksTI, { Size = rockSize })
				rockTween:Play()

				task.spawn(function()
					task.wait(1)

					local fallTween =
						ts:Create(rock, rocksTI, { Position = rock.Position - Vector3.new(0, rock.Size.Y / 2, 0) })

					fallTween:Play()
					fallTween.Completed:Wait()

					rock:Destroy()
				end)
			end
		end

		task.wait(0.05)
	end
end

function displayAttack(pos: Vector3, radius: number)
	--local attackPart = partEffects:WaitForChild("Attack"):Clone()
	--game:GetService("Debris"):AddItem(attackPart, 30)

	--local attackSound = soundEffects:WaitForChild("Attack"):Clone()
	--attackSound.Parent = attackPart

	--setParticleRateZero(attackPart)
	--attackPart.Position = pos
	--attackPart.Parent = workspace["EFFECTS CONTAINER"]

	--attackSound:Play()

	task.spawn(groundSmash.createDebris, pos, radius)
	--task.spawn(particleSequence, attackPart)
end

--effectsRE.OnClientEvent:Connect(displayAttack)

return groundSmash
