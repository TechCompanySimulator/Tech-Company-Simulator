local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")

local MainInterface = Roact.Component:extend("MainInterface")

function MainInterface:init()

end

function MainInterface:render()
	local children = {}

	return Roact.createElement("ScreenGui", {
		Name = "MainInterface";
	}, children)
end

return MainInterface