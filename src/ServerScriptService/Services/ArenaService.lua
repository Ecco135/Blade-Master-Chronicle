local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Pakcages.Knit)

local ArenaService = Knit.CreateService{
    Name = "ArenaService";
    Client = {};
}

function ArenaService:StartGame()

end

function ArenaService:KnitInit()
    print("ArenaService initialized")
end

function ArenaService:KnitStart()
    print("ArenaService started")
end

return ArenaService