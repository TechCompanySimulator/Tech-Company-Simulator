local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")

local buttonTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.Elements.CloseButton)

local e = React.createElement

local function closeButton(props)
	return e(buttonTemplate, {
		[RoactTemplate.Root] = Llama.Dictionary.join({
			[React.Event.MouseButton1Click] = props.onClick;
		}, props.buttonProps or {})
	})
end

return closeButton