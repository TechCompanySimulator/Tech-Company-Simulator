local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")
local Llama = loadModule("Llama")

local AutoResizeScrollFrame = loadComponent("AutoResizeScrollFrame")
local BuildModeItem = loadComponent("BuildModeItem")

local frameTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.CategoryFrame)

local e = React.createElement

local camera = workspace.CurrentCamera

local function buildModeUI(props)
	local config = props.config
	local tiles = {}
	-- Can change this in the future to have separate pages for each category instead of having all categories in this one frame
	for variation, items in config do
		for _, itemData in items do
			table.insert(tiles, e(BuildModeItem, {
				itemData = itemData;
				category = props.category;
				variation = variation;
				selectionInfo = props.selectionInfo;
				setSelectionInfo = props.setSelectionInfo;
			}))
		end
	end

	return e(frameTemplate, {
		[RoactTemplate.Root] = {
			Visible = props.visible;
			[React.Children] = {
				ScrollingFrame = e(AutoResizeScrollFrame, {
					frameProps = {
						Size = UDim2.fromScale(0.98, 0.9);
						Position = UDim2.fromScale(0.5, 0.5);
						AnchorPoint = Vector2.new(0.5, 0.5);
					};
					gridLayout = true;
					layoutProps = {
						CellPadding = UDim2.fromOffset(0.009259 * camera.ViewportSize.Y, 0.009259 * camera.ViewportSize.Y);
						CellSize = UDim2.fromOffset(0.09259 * camera.ViewportSize.Y, 0.09259 * camera.ViewportSize.Y);
						FillDirection = Enum.FillDirection.Horizontal;
						HorizontalAlignment = Enum.HorizontalAlignment.Left;
						VerticalAlignment = Enum.VerticalAlignment.Top;
						SortOrder = Enum.SortOrder.LayoutOrder;
					};
					tiles = e(React.Fragment, {}, tiles);
				});
			}
		};

		BackButton = {
			[React.Event.MouseButton1Click] = function()
				props.setSelectionInfo(Llama.Dictionary.join(props.selectionInfo, {
					category = Llama.None;
				}))
			end;
		};
	})
end

return buildModeUI