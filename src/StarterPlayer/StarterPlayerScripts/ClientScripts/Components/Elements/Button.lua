local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")
local Table = loadModule("Table")

local UICorner = loadModule("UICorner")

local Button = Roact.Component:extend("Button")

Button.buttonStyles = {
	Standard = {
		default = Color3.fromRGB(22, 177, 255);
		hover = Color3.fromRGB(42, 197, 255);
	};
	Confirm = {
		default = Color3.fromRGB(10, 255, 10);
		hover = Color3.fromRGB(30, 255, 30);
	};
	Cancel = {
		default = Color3.fromRGB(255, 10, 10);
		hover = Color3.fromRGB(255, 30, 30);
	};
	Upgrade = {
		default = Color3.fromRGB(239, 184, 56);
		hover = Color3.fromRGB(259, 204, 76);
	};
	Disabled = {
		default = Color3.fromRGB(140, 140, 140);
		hover = Color3.fromRGB(140, 140, 140);
	}
}

function Button:init()
	self.props.buttonStyle = self.props.buttonStyle or "Standard"
	self.colour, self.setColour = Roact.createBinding(Button.buttonStyles[self.props.buttonStyle].default)
end

function Button:render()
	local isActive = self.props.active or (self.props.buttonStyle ~= "Disabled")

	return Roact.createElement("TextButton", Table.merge({
		Active = isActive;
		FontSize = Enum.FontSize.Size14;
		TextColor3 = Color3.new(255, 255, 255);
		BackgroundColor3 = self.colour;
		AutoButtonColor = false;
		Text = self.props.text;
		Size = UDim2.new(1, 0, 1, 0);
		Font = Enum.Font.SciFi;
		TextTruncate = Enum.TextTruncate.AtEnd;
		RichText = true;
		TextScaled = true;
		[Roact.Event.MouseEnter] = isActive and function(...)
			self.setColour(self.buttonStyles[self.props.buttonStyle].hover)

			if self.props.onMouseEnter then
				self.props.onMouseEnter(...)
			end
		end or nil;
		[Roact.Event.MouseLeave] = isActive and function(...)
			self.setColour(self.buttonStyles[self.props.buttonStyle].default)

			if self.props.onMouseLeave then
				self.props.onMouseLeave(...)
			end
		end or nil;
		[Roact.Event.MouseButton1Click] = isActive and function(...)
			self.setColour(self.buttonStyles[self.props.buttonStyle].default)
			if self.props.onClick then
				self.props.onClick(...)
			end
		end or nil;
	}, self.props.buttonProps), {
		UICorner = UICorner(0.25, 0);
	});
end

function Button:didUpdate()
	self.setColour(Button.buttonStyles[self.props.buttonStyle].default)
end

return Button