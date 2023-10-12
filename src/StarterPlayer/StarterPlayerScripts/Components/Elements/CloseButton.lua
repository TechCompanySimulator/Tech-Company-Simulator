local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")

local buttonTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.CloseButton)

local e = React.createElement

return function(props)
	local zIndex = props.ZIndex or 100

	return e(buttonTemplate, {
		[RoactTemplate.Root] = Llama.Dictionary.join({
			[React.Event.MouseButton1Click] = props.onClick;
			ZIndex = zIndex;
		}, props.buttonProps or {});

		Text = {
			ZIndex = zIndex + 1;
		};
	})
end
