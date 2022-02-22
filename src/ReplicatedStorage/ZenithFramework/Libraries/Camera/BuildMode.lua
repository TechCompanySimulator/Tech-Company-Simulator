local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")

return function(self)
	
end