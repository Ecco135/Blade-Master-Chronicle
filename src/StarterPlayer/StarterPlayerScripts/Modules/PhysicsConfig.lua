local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local PhysicsConfig = {}

local attachment = Instance.new("Attachment")
attachment.Name = "linearVelocityAttachment0"
attachment.Parent = HumanoidRootPart

PhysicsConfig.linearVelocity = Instance.new("LinearVelocity")
PhysicsConfig.linearVelocity.Attachment0 = attachment
PhysicsConfig.linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
PhysicsConfig.linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
PhysicsConfig.linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
PhysicsConfig.linearVelocity.MaxForce = math.huge
PhysicsConfig.linearVelocity.Enabled = false
PhysicsConfig.linearVelocity.Parent = HumanoidRootPart

return PhysicsConfig
