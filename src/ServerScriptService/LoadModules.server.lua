local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

require:LoadAll()

local ChessHandler = require("ChessHandler")

task.wait(10)
ChessHandler.newGame(Players:WaitForChild("Player1"), Players:WaitForChild("Player2"), workspace.ChessBoard)