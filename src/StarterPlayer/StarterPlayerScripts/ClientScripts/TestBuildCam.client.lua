local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local BuildModeSystem = loadModule("BuildModeSystem")

task.wait(5)

BuildModeSystem.enter()

