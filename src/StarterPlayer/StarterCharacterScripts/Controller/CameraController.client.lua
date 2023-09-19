local Players = game:GetService("Players")
--local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local Character = player.Character
local root = Character:WaitForChild("HumanoidRootPart")

function focusControl()
	Camera.CameraType = Enum.CameraType.Follow
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	UIS.MouseIconEnabled = false
end

function DefaultControl()
	Camera.CameraType = Enum.CameraType.Custom
	UIS.MouseBehavior = Enum.MouseBehavior.Default
	UIS.MouseIconEnabled = true
end

function CameraUpdate()
	local lookingCFrame = CFrame.lookAt(root.Position, Camera.CFrame:PointToWorldSpace(Vector3.new(0, 0, -100000)))
	root.CFrame = CFrame.fromMatrix(root.Position, lookingCFrame.XVector, lookingCFrame.YVector)
end

Character.ChildAdded:Connect(function(child)
	if child.name == "Sword" then
		focusControl()
		--activate the following to have character follow camera view
		--RunService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value, CameraUpdate)
	end
end)
Character.ChildRemoved:Connect(function(child)
	if child.name == "Sword" then
		DefaultControl()
		--activate the following if character follow is activated
		--RunService:UnbindFromRenderStep("CameraUpdate")
	end
end)
