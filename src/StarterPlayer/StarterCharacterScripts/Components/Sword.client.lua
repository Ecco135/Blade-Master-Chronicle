local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local TS = game:GetService("TweenService")
local debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local dashConfig = require(script.Parent.Parent:WaitForChild("Modules").DashConfig)
local groundSmash = require(script.Parent.Parent:WaitForChild("Modules").GroundSmashVisual)
local MovementConfig = require(script.Parent.Parent.Modules.MovementConfig)
local CombatConfig = require(script.Parent.Parent.Modules.CombatConfig)

local SwordcutEvent = ReplicatedStorage.Event:WaitForChild("SwordcutEvent")

local animationTrack = nil
local nextslashinput = false
local animationstate = false

local Sword = nil
local idlePlay = nil
local runPlay = nil
local runConnect = nil
local blastWave = false
local blastConnect = nil
CombatConfig.slashCount = 1

local textures = { -- Slash
	"rbxassetid://8896641723", --9
	"rbxassetid://8821300395", --7
	"rbxassetid://8821300395", --7
	"rbxassetid://8821272181", --5
	"rbxassetid://8821272181", --5
	"rbxassetid://8821254467", --4
	"rbxassetid://8821246947", --3
	"rbxassetid://8821193347", --1
	"rbxassetid://8821246947", --3
	"rbxassetid://8821254467", --4
	"rbxassetid://8821272181", --5
	"rbxassetid://8821300395", --7
	"rbxassetid://8896641723", --9
}

local swordL = {}
local slashPlay = {}
for _, v in pairs(Character.MotionAni.SwordL:GetChildren()) do
	local animator = Humanoid:FindFirstChildOfClass("Animator")
	swordL[tonumber(v.name:sub(-1))] = v
	slashPlay[tonumber(v.name:sub(-1))] = animator:LoadAnimation(v)
end

--local swordslashT = 0.1
local swordstep = { 15, 17, 17, 17, 0 }

local function slashconnect(otherPart)
	if otherPart.Parent ~= Sword.Parent then
		SwordcutEvent:FireServer(otherPart)
	end
end

local function groundBlast(_, newState)
	local m1pressed = false
	for _, v in pairs(UIS:GetMouseButtonsPressed()) do
		if v.UserInputType.Name == "MouseButton1" then
			m1pressed = true
		end
	end
	if newState == Enum.HumanoidStateType.Running and blastWave == false and m1pressed then
		print("blast wave")
		blastWave = true

		local groundPos = HumanoidRootPart.Position - Vector3.new(0, HumanoidRootPart.Position.Y + 1.5, 0)

		task.spawn(groundSmash.createDebris, groundPos, 10)
		local blastDome = Instance.new("Part")
		blastDome.Shape = "Ball"
		blastDome.Size = Vector3.new(0.01, 0.01, 0.01)
		blastDome.Transparency = 0.5
		blastDome.Anchored = true
		blastDome.CanCollide = false
		blastDome.CanTouch = true
		blastDome.Position = groundPos
		blastDome.Parent = Sword.Parent

		blastDome.Touched:Connect(slashconnect)

		TS:Create(blastDome, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Size = Vector3.new(20, 20, 20) })
			:Play()

		debris:AddItem(blastDome, 0.3)
		task.wait(1)
		blastWave = false
		blastConnect:Disconnect()
	end
end

local function playAnimationFromServer(animationID)
	--[[
	local animator = Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		animationTrack = Humanoid:LoadAnimation(animationID)
		animationTrack.Priority = Enum.AnimationPriority.Action2
		animationTrack:Play()
	end
	]]
	--animationTrack = slashPlay[animationID]
	--animationTrack:Play()
	slashPlay[animationID]:Play()
	return slashPlay[animationID]
end

local function comboRefresh()
	task.wait(0.6)
	if tick() - nextslashinput > 0.6 then
		CombatConfig.slashCount = 1
		if blastConnect then
			blastConnect:Disconnect()
		end
		CombatConfig.slashdebounce = false
	end
end

local function slashBox(comboN)
	local SlashEffect = ReplicatedStorage.VFX.MotionEffect.SlashEffect:Clone()
	local HitBox2 = nil
	local HitBox1 = ReplicatedStorage.VFX.MotionEffect.HitBox:Clone()
	debris:AddItem(SlashEffect, 0.6)

	HitBox1:WaitForChild("HitBox").Touched:Connect(slashconnect)
	if comboN == 1 then
		task.wait(0.1)
		SlashEffect.PrimaryPart.CFrame = HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(30))
		HitBox1.PrimaryPart.CFrame = SlashEffect.PrimaryPart.CFrame
		TS:Create(
			SlashEffect.PrimaryPart,
			TweenInfo.new(0.35),
			{ CFrame = SlashEffect.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(178), 0) }
		):Play()
		TS:Create(SlashEffect.Slash, TweenInfo.new(0.35), { Transparency = 1 }):Play()
	elseif comboN == 2 then
		task.wait(0.1)
		SlashEffect.PrimaryPart.CFrame = HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(150))
		HitBox1.PrimaryPart.CFrame = SlashEffect.PrimaryPart.CFrame
		TS:Create(
			SlashEffect.PrimaryPart,
			TweenInfo.new(0.35),
			{ CFrame = SlashEffect.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(178), 0) }
		):Play()
		TS:Create(SlashEffect.Slash, TweenInfo.new(0.35), { Transparency = 1 }):Play()
	elseif comboN == 3 then
		task.wait(0.1)
		SlashEffect.PrimaryPart.CFrame = HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(0), 0)
		HitBox1.PrimaryPart.CFrame = SlashEffect.PrimaryPart.CFrame
		HitBox2 = ReplicatedStorage.VFX.MotionEffect.HitBox:Clone()
		HitBox2:WaitForChild("HitBox").Touched:Connect(slashconnect)
		HitBox2.PrimaryPart.CFrame = HitBox1.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)
		TS:Create(
			SlashEffect.PrimaryPart,
			TweenInfo.new(0.35),
			{ CFrame = SlashEffect.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(178), 0) }
		):Play()
		TS:Create(SlashEffect.Slash, TweenInfo.new(0.35), { Transparency = 1 }):Play()
	elseif comboN == 4 then
		task.wait(0.1)
		SlashEffect.PrimaryPart.CFrame = HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(-90))
		HitBox1.PrimaryPart.CFrame = SlashEffect.PrimaryPart.CFrame
		TS:Create(
			SlashEffect.PrimaryPart,
			TweenInfo.new(0.35),
			{ CFrame = SlashEffect.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(178), 0) }
		):Play()
		TS:Create(SlashEffect.Slash, TweenInfo.new(0.35), { Transparency = 1 }):Play()
	elseif comboN == 5 then
		task.wait(0.1)
		SlashEffect.PrimaryPart.CFrame = HumanoidRootPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(90))
		HitBox1.PrimaryPart.CFrame = SlashEffect.PrimaryPart.CFrame
		TS:Create(
			SlashEffect.PrimaryPart,
			TweenInfo.new(0.35),
			{ CFrame = SlashEffect.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(178), 0) }
		):Play()
		TS:Create(SlashEffect.Slash, TweenInfo.new(0.35), { Transparency = 1 }):Play()
	end

	local connection
	local count = 1
	connection = runService.RenderStepped:Connect(function()
		SlashEffect.Slash.Mesh.TextureId = textures[count]
		count = count + 1
		if count > #textures then
			count = 1
			connection:Disconnect()
		end
	end)

	local patInit = tick()
	local particleC = 0
	local patCon
	patCon = runService.RenderStepped:Connect(function()
		if tick() - patInit < 0.3 then
			particleC = particleC + 1
			for _, v in pairs(SlashEffect.Effect1:GetChildren()) do
				if v:IsA("ParticleEmitter") and particleC % 2 == 0 then
					v:Emit(1)
				end
			end
		else
			patCon:Disconnect()
		end
	end)

	TS:Create(SlashEffect.Slash.light, TweenInfo.new(0.3), { Brightness = 0 }):Play()
	SlashEffect.Parent = Sword.Parent
	HitBox1.Parent = Sword.Parent
	HitBox1.HitBox.CanTouch = true
	HitBox1.HitBox.Touched:Connect(slashconnect)
	if HitBox2 then
		HitBox2.Parent = Sword.Parent
		HitBox2.HitBox.CanTouch = true
		HitBox2.HitBox.Touched:Connect(slashconnect)
	end
	debris:AddItem(HitBox1, 0.1)
	debris:AddItem(HitBox2, 0.1)
end

local function SwordL(_, inputState)
	if
		inputState == Enum.UserInputState.Begin
		and CombatConfig.slashdebounce == false
		and Character.stunt.Value == false
	then
		nextslashinput = tick()
		CombatConfig.slashdebounce = true
		Humanoid.JumpPower = 0
		if Humanoid.WalkSpeed == dashConfig.WalkSpeed then
			Humanoid.WalkSpeed = 0.1
		end

		if CombatConfig.slashCount < 5 then
			if animationstate == true then
				if CombatConfig.slashCount ~= 4 then
					animationTrack.KeyframeReached:Wait()
				else
					animationTrack.KeyframeReached:Wait()
				end
				if Character.stunt.Value == true then
					CombatConfig.slashdebounce = false
					Humanoid.JumpPower = 50
					return
				end
			end
			if Character.stunt.Value == true then
				return
			end

			--if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			--	CombatConfig.slashCount = 5
			--end
		end

		animationstate = true
		--animationTrack = playAnimationFromServer(swordL[CombatConfig.slashCount])
		animationTrack = playAnimationFromServer(CombatConfig.slashCount)
		Sword.BladeBox.CanTouch = true
		slashBox(CombatConfig.slashCount)

		if CombatConfig.slashCount == 4 then
			task.wait(0.1)
			Humanoid.JumpPower = 60
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		elseif CombatConfig.slashCount == 5 then
			blastConnect = Humanoid.StateChanged:Connect(groundBlast)

			HumanoidRootPart:ApplyImpulse(Vector3.new(0, 1000, 0))
			task.wait(0.1)
			HumanoidRootPart:ApplyImpulse(Vector3.new(0, -5000, 0))
		else
			task.wait(0.1)
		end

		local direction = HumanoidRootPart.CFrame.LookVector
		local planeDirection = Vector2.new(direction.X, direction.Z)
		HumanoidRootPart.LinearVelocity.PlaneVelocity = swordstep[CombatConfig.slashCount] * planeDirection
		Humanoid.AutoRotate = false
		HumanoidRootPart.LinearVelocity.Enabled = true

		if CombatConfig.slashCount < 5 then
			CombatConfig.slashCount = CombatConfig.slashCount + 1
			CombatConfig.slashdebounce = false
		end

		dashConfig.dashCD = true
		task.spawn(comboRefresh)

		if CombatConfig.slashCount == 5 then
			animationTrack.KeyframeReached:Wait()
		else
			animationTrack.KeyframeReached:Wait()
		end
		if Humanoid.JumpPower ~= 50 then
			Humanoid.JumpPower = 50
		end
		if Character.stunt.Value == false then
			Humanoid.WalkSpeed = dashConfig.WalkSpeed
		end

		Sword.BladeBox.CanTouch = false
		HumanoidRootPart.LinearVelocity.Enabled = false
		animationTrack:Destroy()
		HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + direction)
		Humanoid.AutoRotate = true
		dashConfig.dashCD = false

		animationstate = false
	end
end

local function movementAni()
	if MovementConfig.IsWalking() and Humanoid:GetState() == Enum.HumanoidStateType.Running then
		if not runPlay.IsPlaying then
			runPlay:Play()
		end
		if runPlay.IsPlaying then
			if Humanoid.WalkSpeed == dashConfig.WalkSpeed then
				runPlay:AdjustSpeed(1)
				HumanoidRootPart.Running.PlaybackSpeed = 1.5
			else
				runPlay:AdjustSpeed(1.5)
				HumanoidRootPart.Running.PlaybackSpeed = 2.25
			end
		end
		if idlePlay.IsPlaying then
			idlePlay:Stop()
		end
	else
		if runPlay.IsPlaying then
			runPlay:Stop()
		end
		if
			not idlePlay.IsPlaying
			and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping
			and Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall
		then
			idlePlay:Play()
		end
	end
end

Character.ChildAdded:Connect(function(child)
	if child.Name == "Sword" then
		print("sword combat binded")
		Sword = child
		ContextActionService:BindAction("SwordL", SwordL, false, Enum.UserInputType.MouseButton1)
		local idleAnimation = Sword:WaitForChild("Animation").Idle
		idlePlay = Humanoid.Animator:LoadAnimation(idleAnimation)
		local runAnimation = Sword.Animation.Run
		runPlay = Humanoid.Animator:LoadAnimation(runAnimation)
		runConnect = runService.Heartbeat:Connect(movementAni)
	end
end)

Character.ChildRemoved:Connect(function(child)
	if child.Name == "Sword" then
		ContextActionService:UnbindAction("SwordL")
		runConnect:Disconnect()
	end
end)
