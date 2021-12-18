local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")

local MainMenu = Roact.Component:extend("MainMenu")

function MainMenu:render()
	return Roact.createElement("ScreenGui", {
		Enabled = self.props.visible
	}, {
		Background = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(0.5, 0, 0.5, 0)
		})
	})
end

return MainMenu