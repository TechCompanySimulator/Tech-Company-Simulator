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
		enabled = false;
		selectedCategory = "Main";
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
		Enabled = self.state.enabled;
	}, {
		Frame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(0.557, 0, 0.576, 0);
			BackgroundColor3 = Color3.new(1, 1, 1);
		}, {
			UICorner = UICorner(0.05, 0);
	
			Title = Roact.createElement("TextLabel", {
				FontSize = Enum.FontSize.Size14;
				TextColor3 = Color3.new(0, 0, 0);
				Text = "Inventory";
				Font = Enum.Font.SourceSansBold;
				BackgroundTransparency = 1;
				Position = UDim2.new(0.361, 0, 0, 0);
				Name = "Title";
				Size = UDim2.new(0.276, 0, 0.1, 0);
				TextScaled = true;
				BackgroundColor3 = Color3.new(1, 1, 1);
			});
	
			CategoryButtons = multipleCategories and Roact.createElement("ScrollingFrame", {
				ScrollBarImageColor3 = Color3.new(0, 0, 0);
				Active = true;
				Name = "CategoryButtons";
				Size = UDim2.new(0.967, 0, 0.079, 0);
				BackgroundTransparency = 1;
				Position = UDim2.new(0.012, 0, 0.1, 0);
				HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
				BackgroundColor3 = Color3.new(1, 1, 1);
				BorderSizePixel = 0;
				CanvasSize = self.categoryCanvasSize;
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center;
					FillDirection = Enum.FillDirection.Horizontal;
					SortOrder = Enum.SortOrder.LayoutOrder;
					[Roact.Change.AbsoluteContentSize] = function(ui)
						self.setCategoryCanvasSize(UDim2.new(0, ui.AbsoluteContentSize.X, 0, 0))
					end
				});
	
				Buttons = Roact.createFragment(categoryButtons);
			});
	
			ItemsFrame = Roact.createElement("ScrollingFrame", {
				ScrollBarImageColor3 = Color3.new(0, 0, 0);
				Active = true;
				AnchorPoint = Vector2.new(0.5, 1);
				Name = "ItemsFrame";
				Position = UDim2.new(0.5, 0, 1, 0);
				Size = UDim2.new(1, 0, 0.82, 0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1, 1, 1);
				CanvasSize = self.canvasSize;
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0.02, 0);
					PaddingBottom = UDim.new(0.02, 0);
					PaddingRight = UDim.new(0.05, 0);
					PaddingLeft = UDim.new(0.05, 0);
				});
	
				UIGridLayout = Roact.createElement("UIGridLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder;
					CellSize = UDim2.new(0, itemTileSize, 0, itemTileSize);
					CellPadding = UDim2.new(0.03, 0, 0.03, 0);
					HorizontalAlignment = Enum.HorizontalAlignment.Center;
					[Roact.Change.AbsoluteContentSize] = function(ui)
						self.setCanvasSize(UDim2.new(0, 0, 0, ui.AbsoluteContentSize.Y + itemTileSize / 3))
					end
				}, {
					UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint");
				});

				ItemTile = Roact.createFragment(itemTiles);
			});
		});
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