local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")

local ThemeContext = loadComponent("ThemeContext")
local BuildModeButtons = loadComponent("BuildModeButtons")
local BuildModeCategoryFrame = loadComponent("BuildModeCategoryFrame")

local e = React.createElement
local useState = React.useState

local categories = {
	machines = {
		layoutOrder = 1;
		name = "Machines";
	};
	decorations = {
		layoutOrder = 2;
		name = "Decorations";
	};
}

local function buildModeUI(props)
	local selectionInfo, setSelectionInfo = useState({})

	local categoryFrames = {}
	for category, info in pairs(categories) do
		local frame = e(BuildModeCategoryFrame, {
			visible = selectionInfo.category == category;
			selectionInfo = selectionInfo;
			setSelectionInfo = setSelectionInfo;
		})

		categoryFrames[category] = frame
	end

	return e(React.Fragment, {}, 
		{
			CategoryButtons = props.visible and not selectionInfo.category and e(BuildModeButtons, {
				categories = categories;
				selectionInfo = selectionInfo;
				setSelectionInfo = setSelectionInfo;
			});
			
			CategoryFrames = e(React.Fragment, {}, categoryFrames);
		}
	)
end

return buildModeUI