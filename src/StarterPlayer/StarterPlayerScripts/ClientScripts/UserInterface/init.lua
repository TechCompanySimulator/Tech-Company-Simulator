local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Player = Players.LocalPlayer

local Roact = require("Roact")
local RoactRodux = require("RoactRodux")
local RoduxStore = require("RoduxStore")
local MainInterface = require("MainInterface")

local UserInterface = Roact.createElement(RoactRodux.StoreProvider, {
	store = RoduxStore,
}, {
	MainInterface = Roact.createElement(MainInterface),
})

Roact.mount(UserInterface, Player:WaitForChild("PlayerGui"))

return UserInterface