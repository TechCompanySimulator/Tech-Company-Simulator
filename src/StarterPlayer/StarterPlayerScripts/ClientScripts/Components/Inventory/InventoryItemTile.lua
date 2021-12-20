local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")

local InventoryItemTile = Roact.Component:extend("InventoryItemTile")

function InventoryItemTile:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 100, 0, 100);
		Name = "ItemTile";
		BackgroundColor3 = Color3.new(0.812, 0.992, 1);
		SizeConstraint = Enum.SizeConstraint.RelativeYY;
	}, {
		ItemName = Roact.createElement("TextLabel", {
			FontSize = Enum.FontSize.Size14;
			TextColor3 = Color3.new(0, 0, 0);
			Text = self.props.itemName;
			Font = Enum.Font.SourceSansBold;
			BackgroundTransparency = 1;
			Position = UDim2.new(0.13, 0, 0.031, 0);
			Name = "ItemName";
			Size = UDim2.new(0.738, 0, 0.241, 0);
			TextScaled = true;
			BackgroundColor3 = Color3.new(1, 1, 1);
		});

		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.2, 0);
		});
	});
end

return InventoryItemTile