local ReplicatedStorage = game:GetService("ReplicatedStorage")

local framework, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local UserInterface = loadComponent("UserInterface")

task.spawn(UserInterface.initiate)

framework:loadAll()
