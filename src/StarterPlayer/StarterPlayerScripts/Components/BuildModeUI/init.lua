local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoduxStore = loadModule("RoduxStore")
local BuildModeSystem = loadModule("BuildModeSystem")
local RoactTemplate = loadModule("RoactTemplate")

local BuildModeButtons = loadComponent("BuildModeButtons")
local BuildModeCategoryFrame = loadComponent("BuildModeCategoryFrame")

local exitButton = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.ExitButton)
local deleteButton = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.DeleteButton)

local e = React.createElement
local useState = React.useState

local function buildModeUI(props)
	if not props.visible then return end
	
	local selectionInfo, setSelectionInfo = useState({})

	if next(selectionInfo) and BuildModeSystem.deleteModeActive then
		BuildModeSystem.toggleDeleteMode(false)
	end

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
			});

			DeleteButton = e(deleteButton, {
				[RoactTemplate.Root] = {
					[React.Event.MouseButton1Click] = function()
						BuildModeSystem.toggleDeleteMode()
						setSelectionInfo({})
					end;

					BackgroundColor3 = BuildModeSystem.deleteModeActive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(129, 129, 129);
				};
			});
		}
	)
end

return buildModeUI