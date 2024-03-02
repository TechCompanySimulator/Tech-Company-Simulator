local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoduxStore = loadModule("RoduxStore")

local BuildModeButtons = loadComponent("BuildModeButtons")
local BuildModeCategoryFrame = loadComponent("BuildModeCategoryFrame")

local e = React.createElement
local useState = React.useState

local function buildModeUI(props)
	local selectionInfo, setSelectionInfo = useState({})

	local categories = RoduxStore:getState().gameValues.shopConfig.categories

	local categoryFrames = {}
	for category, info in categories do
		local categoryConfig = RoduxStore:getState().gameValues.shopConfig[category]
		local frame = e(BuildModeCategoryFrame, {
			layoutOrder = info.layoutOrder;
			visible = selectionInfo.category == category;
			config = categoryConfig;
			category = category;
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