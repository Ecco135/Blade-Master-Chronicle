local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local Character = player.Character
local root = Character:WaitForChild("HumanoidRootPart")
local CameraAngleX = 0
local CameraAngleY = 0
local CameraOffset = Vector3.new(0, 3, 12)

function focusControl()
	Camera.CameraType = Enum.CameraType.Scriptable
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	UIS.MouseIconEnabled = false
end

function DefaultControl()
	Camera.CameraType = Enum.CameraType.Custom
	UIS.MouseBehavior = Enum.MouseBehavior.Default
	UIS.MouseIconEnabled = true
end

function MouseInput(_, inputState, inputObject)
	if inputState == Enum.UserInputState.Change then
		CameraAngleX -= inputObject.Delta.X
		CameraAngleY = math.clamp(CameraAngleY - inputObject.Delta.Y * 0.4, -45, 45)
	end
end

function CameraUpdate()
	local startCFrame = CFrame.new(root.CFrame.Position)
		* CFrame.Angles(0, math.rad(CameraAngleX), 0)
		* CFrame.Angles(math.rad(CameraAngleY), 0, 0)
	local cameraCFrame = startCFrame:PointToWorldSpace(CameraOffset)
	local cameraFocus = startCFrame:PointToWorldSpace(Vector3.new(CameraOffset.X, CameraOffset.Y, -100000))
	Camera.CFrame = CFrame.lookAt(cameraCFrame, cameraFocus)

	local lookingCFrame = CFrame.lookAt(root.Position, Camera.CFrame:PointToWorldSpace(Vector3.new(0, 0, -100000)))
	root.CFrame = CFrame.fromMatrix(root.Position, lookingCFrame.XVector, lookingCFrame.YVector)
end

Character.ChildAdded:Connect(function(child)
	if child.name == "Sword" then
		focusControl()
		CAS:BindAction("MouseInput", MouseInput, false, Enum.UserInputType.MouseMovement)
		RunService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value, CameraUpdate)
	end
end)
Character.ChildRemoved:Connect(function(child)
	if child.name == "Sword" then
		DefaultControl()
		CAS:UnbindAction("MouseInput")
		RunService:UnbindFromRenderStep("CameraUpdate")
	end
end)
