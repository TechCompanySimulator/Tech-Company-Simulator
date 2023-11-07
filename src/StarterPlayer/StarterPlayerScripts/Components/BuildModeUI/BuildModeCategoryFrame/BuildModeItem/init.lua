local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")
local String = loadModule("String")
local ItemPlacementSystem = loadModule("ItemPlacementSystem")

local itemTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.TemplateItem)

local e = React.createElement

local function buildModeItem(props)
	return e(itemTemplate, {
		[RoactTemplate.Root] = {
			[React.Event.MouseButton1Click] = function()
				print("Purchase item: " , props.itemData.displayName)
				ItemPlacementSystem.startPlacement(props.category, props.variation, props.itemData.id)
			end;
		};

		ItemImage = {
			Image = props.itemData.image;
		};

		ItemName = {
			Text = props.itemData.displayName;
		};

		ItemCost = {
			Text = "$" .. String.commaFormat(props.itemData.price.amount);
		};
	})
end

return buildModeItem