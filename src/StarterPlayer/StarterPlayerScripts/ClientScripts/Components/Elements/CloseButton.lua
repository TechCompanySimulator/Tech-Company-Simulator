--[[
	Needed props:
	setEnabled - Binding sent from the parent component which can be called to set the component to enabled == false

	Optional props:
	buttonProps - Optional props to change the properties of the close button
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")
local Table = loadModule("Table")

local CloseButton = Roact.Component:extend("CloseButton")

function CloseButton:render()
	return Roact.createElement("TextButton", Table.merge(self.props.buttonProps or {}, {
		FontSize = Enum.FontSize.Size14;
		TextColor3 = Color3.new(1, 0, 0);
		Text = "X";
		Name = "Close";
		AnchorPoint = Vector2.new(1, 0);
		Font = Enum.Font.GothamSemibold;
		BackgroundTransparency = 1;
		Position = UDim2.new(0.99, 0, 0.01, 0);
		SizeConstraint = Enum.SizeConstraint.RelativeXX;
		Size = UDim2.new(0.1, 0, 0.1, 0);
		TextScaled = true;
		BackgroundColor3 = Color3.new(1, 1, 1);
		[Roact.Event.MouseButton1Click] = function()
			if self.props.setEnabled then
				self.props.setEnabled(false)
			end
		end;
	}))
end

return CloseButton