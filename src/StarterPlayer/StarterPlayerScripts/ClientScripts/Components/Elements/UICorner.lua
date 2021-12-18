local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")

local UICorner = Roact.Component:extend("UICorner")

function UICorner:render()
	return Roact.createElement("UICorner", {
		CornerRadius = UDim.new(self.props.scale, self.props.offset)
	})
end

return function(scale, offset)
	return Roact.createElement(UICorner,{
		scale = scale;
		offset = offset;
	})
end
