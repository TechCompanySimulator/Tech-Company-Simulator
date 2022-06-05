local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")
local RoactRodux = loadModule("RoactRodux")
local Table = loadModule("Table")

local UICorner = loadModule("UICorner")
local InventoryItemTile = loadModule("InventoryItemTile")

local Inventory = Roact.Component:extend("Inventory")

function Inventory:init()
	self:setState({
		selectedCategory = "Main"
	})

	self.canvasSize, self.setCanvasSize = Roact.createBinding(UDim2.new(0, 0, 0, 0))
	self.categoryCanvasSize, self.setCategoryCanvasSize = Roact.createBinding(UDim2.new(0, 0, 0, 0))
end

function Inventory:render()
	local inventoryData = self.props.inventoryData
	local itemTiles = {}
	local categoryButtons = {}

	local itemTileSize = Camera.ViewportSize.X / 10

	if inventoryData and inventoryData[self.state.selectedCategory] then
		for _, item in pairs(inventoryData[self.state.selectedCategory]) do
			table.insert(itemTiles, Roact.createElement(InventoryItemTile, {
				itemName = item.name;
			}))
		end
	end

	local multipleCategories = Table.length(inventoryData) > 1
	if multipleCategories then
		for categoryName, _ in pairs(inventoryData) do
			table.insert(categoryButtons, Roact.createElement("TextButton", {
				FontSize = Enum.FontSize.Size14;
				TextColor3 = Color3.new(1, 1, 1);
				Text = categoryName;
				AnchorPoint = Vector2.new(0.5, 0.5);
				Font = Enum.Font.SourceSansBold;
				Name = "Button1";
				Size = UDim2.new(0.1, 0, 0.9, 0);
				TextScaled = true;
				BackgroundColor3 = Color3.new(1, 0, 0);
			}, {
				UICorner = UICorner(0.3, 0);
			}))
		end
	end
	
	return Roact.createElement("ScreenGui", {
		Name = "InventoryTest";
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	}, {
	})
end

Inventory = RoactRodux.connect(function(state, props)
	local playerData = state.playerData or {}
	local playersData = playerData[tostring(Player.UserId)] or {}
	local inventoryData = playersData.Inventory or {}

	return {
		inventoryData = inventoryData;
	}
end)(Inventory)

return Inventory