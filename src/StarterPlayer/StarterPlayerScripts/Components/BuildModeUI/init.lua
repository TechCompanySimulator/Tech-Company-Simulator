local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")
local RoduxStore = loadModule("RoduxStore")
local BuildModeSystem = loadModule("BuildModeSystem")

local ThemeContext = loadComponent("ThemeContext")
local BuildModeButtons = loadComponent("BuildModeButtons")
local BuildModeCategoryFrame = loadComponent("BuildModeCategoryFrame")

local exitButton = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.ExitButton)

local e = React.createElement
local useState = React.useState

local function buildModeUI(props)
	if not props.visible then return end
	
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

			ExitButton = e(exitButton, {
				[RoactTemplate.Root] = {
					[React.Event.MouseButton1Click] = function()
						setSelectionInfo({})
						BuildModeSystem.exit()
					end;
				};
			})
		}
	)
end

return buildModeUI