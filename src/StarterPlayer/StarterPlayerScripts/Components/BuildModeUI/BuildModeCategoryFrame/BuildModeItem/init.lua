local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")

local itemTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.UITemplates.BuildMode.TemplateItem)

local e = React.createElement

local function buildModeItem(props)
	return e(itemTemplate)
end

return buildModeItem