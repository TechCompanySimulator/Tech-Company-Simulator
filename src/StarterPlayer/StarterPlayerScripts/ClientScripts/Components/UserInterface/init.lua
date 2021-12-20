local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Player = Players.LocalPlayer

local Roact = loadModule("Roact")
local RoactRodux = loadModule("RoactRodux")
local RoduxStore = loadModule("RoduxStore")
local MainInterface = loadModule("MainInterface")

local UserInterface = Roact.createElement(RoactRodux.StoreProvider, {
	store = RoduxStore,
}, {
	MainInterface = Roact.createElement(MainInterface),
})

function UserInterface:initiate()
	Roact.mount(UserInterface, Player:WaitForChild("PlayerGui"))
end

return UserInterface