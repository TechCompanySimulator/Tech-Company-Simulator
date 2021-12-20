local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")
local RoactRodux = loadModule("RoactRodux")

local Inventory = Roact.Component:extend("Inventory")

function Inventory:init()

end

function Inventory:render()
	
end

Inventory = RoactRodux:Connect(function(state, props)
	local inventoryData = state.playerData[tostring(Player.UserId)].Inventory or {}

	return {
		inventoryData = inventoryData;
	}
end)(Inventory)

return Inventory