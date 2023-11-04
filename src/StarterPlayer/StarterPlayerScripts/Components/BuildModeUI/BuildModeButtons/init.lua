local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")
local Llama = loadModule("Llama")

local buttonsHolderTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.CategoryButtonsHolder)
local buttonTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.CategoryButton)

local e = React.createElement

local function buildModeButtons(props)
	local categoryButtons = {}

	for category, info in props.categories do
		local button = e(buttonTemplate, {
			[RoactTemplate.Root] = {
				LayoutOrder = info.layoutOrder;
				Text = info.displayName;
				[React.Event.MouseButton1Click] = function()
					props.setSelectionInfo(Llama.Dictionary.join(props.selectionInfo, {
						category = category;
					}))
				end;
			};
		})

		categoryButtons[category] = button
	end
		
	return e(buttonsHolderTemplate, {
		[RoactTemplate.Root] = {
			[React.Children] = categoryButtons;
		}
	})
end

return buildModeButtons