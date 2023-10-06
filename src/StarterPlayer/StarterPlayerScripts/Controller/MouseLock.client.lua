local MouseLockModule = script.Parent.Parent.Parent
	:WaitForChild("PlayerModule")
	:WaitForChild("CameraModule")
	:WaitForChild("MouseLockController")

MouseLockModule:WaitForChild("BoundKeys").Value = "Y"
