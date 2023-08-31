local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local root = Character:WaitForChild("HumanoidRootPart")
local airJumpAni = ReplicatedStorage.VFX.MotionAni:WaitForChild("AirJumpAnimation")
local airJumpPlay = Humanoid:LoadAnimation(airJumpAni)

local dashConfig = require(script.Parent.Parent.Modules.DashConfig)
local TweenCamConfig = require(script.Parent.Parent.Modules.TweenCamConfig)

local JumpEvent = ReplicatedStorage.VFX.MotionEffect:WaitForChild("JumpEvent")

local CharacterController = Knit.CreateController({
	Name = "CharacterController",
})

function CharacterController:KnitStart()
	local shiftKeyP = false
	local WalkSpeed = 16
	local RunSpeed = 25
	local DashRunKey = Enum.KeyCode.LeftShift

	local walkFOV = 70
	local runFOV = 80

	local doubleJumpCount = 0

	local function DashRun(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			if shiftKeyP == false then
				shiftKeyP = true
			end

			dashConfig.dash()

			if shiftKeyP then
				TweenCamConfig.TweenCamera(runFOV)
				Humanoid.WalkSpeed = RunSpeed
			end
		end

		if inputState == Enum.UserInputState.End then
			shiftKeyP = false
			TweenCamConfig.TweenCamera(walkFOV)
			Humanoid.WalkSpeed = WalkSpeed
		end
	end

	local function airJump()
		if doubleJumpCount < 1 then
			if Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				JumpEvent:FireServer(root)
				airJumpPlay:Play()
				airJumpPlay:AdjustSpeed(airJumpPlay.Length / 0.3)
				task.spawn(function()
					doubleJumpCount = 1
				end)
			end
		end
	end

	local function airJumpState(_oldState, newState)
		if newState == Enum.HumanoidStateType.Freefall then
			task.wait(0.2)
			ContextActionService:BindAction("airJump", airJump, false, Enum.KeyCode.Space)
		end
		if newState == Enum.HumanoidStateType.Landed then
			ContextActionService:UnbindAction("airJump")
			doubleJumpCount = 0
		end
	end

	ContextActionService:BindAction("DashRun", DashRun, false, DashRunKey)
	Humanoid.StateChanged:Connect(airJumpState)
end

function CharacterController:KnitInit() end

return CharacterController
