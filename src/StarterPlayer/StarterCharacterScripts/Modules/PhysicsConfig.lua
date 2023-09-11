local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local PhysicsConfig = {}

local attachment = Instance.new("Attachment")
attachment.Name = "LinearVelocityAttachment0"
attachment.Parent = HumanoidRootPart

PhysicsConfig.LinearVelocity = Instance.new("LinearVelocity")
PhysicsConfig.LinearVelocity.Attachment0 = attachment
PhysicsConfig.LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
PhysicsConfig.LinearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
PhysicsConfig.LinearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
PhysicsConfig.LinearVelocity.MaxForce = math.huge
PhysicsConfig.LinearVelocity.Enabled = false
PhysicsConfig.LinearVelocity.Parent = HumanoidRootPart

return PhysicsConfig
