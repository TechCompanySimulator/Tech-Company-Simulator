local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Player = Players.LocalPlayer

local Roact = loadModule("Roact")
local React = loadModule("React")
local RoactRodux = loadModule("RoactRodux")
local RoduxStore = loadModule("RoduxStore")

local MainInterface = loadComponent("MainInterface", true)

local e = React.createElement

local UserInterface = e(RoactRodux.StoreProvider, {
	store = RoduxStore,
}, {
	MainInterface = e(MainInterface),
})

function UserInterface:initiate()
	Roact.mount(UserInterface, Player:WaitForChild("PlayerGui"))
end

return UserInterface