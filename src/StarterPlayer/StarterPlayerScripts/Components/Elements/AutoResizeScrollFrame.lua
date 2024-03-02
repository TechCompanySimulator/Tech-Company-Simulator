--[[
	props:
		tiles: table (the tiles to populate the scrolling frame with)

	optional props:
		frameProps: table (Any property changes for the scrolling frame)
		listLayout: boolean (Use a list layout or not)
		gridLayout: boolean (Use a grid layout or not)
		layoutProps: table (Any property changes for the UILayout object)
		containerProps: table (Any property changes for the Container frame)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local Llama = loadModule("Llama")
local RoactTemplate = loadModule("RoactTemplate")

local e = React.createElement
local useState = React.useState

local autoResizeScrollFrameTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.Elements.AutoResizeScrollFrame)

local function autoResizeScrollFrame(props)
	local canvasSize, setCanvasSize = useState(UDim2.new(0, 0, 0, 0))
	local isList = props.listLayout or not props.gridLayout

	return e(autoResizeScrollFrameTemplate, {
		[RoactTemplate.Root] = Llama.Dictionary.join({
			CanvasSize = canvasSize;
		}, props.frameProps or {});
	
		Container = Llama.Dictionary.join({
			[React.Children] = Llama.Dictionary.join({
				UIListLayout = isList and e("UIListLayout", Llama.Dictionary.join({
					Padding = UDim.new(0.01, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					[React.Change.AbsoluteContentSize] = function(ui)
						local scrollingDirection = props.frameProps and props.frameProps.ScrollingDirection or Enum.ScrollingDirection.XY
						local changeX = scrollingDirection == Enum.ScrollingDirection.XY or scrollingDirection == Enum.ScrollingDirection.X
						local changeY = scrollingDirection == Enum.ScrollingDirection.XY or scrollingDirection == Enum.ScrollingDirection.Y
						
						setCanvasSize(UDim2.new(0, changeX and ui.AbsoluteContentSize.X or 0, 0, changeY and ui.AbsoluteContentSize.Y + 10 or 0))
					end
				}, props.layoutProps or {}));

				UIGridLayout = not isList and e("UIGridLayout", Llama.Dictionary.join({
					SortOrder = Enum.SortOrder.LayoutOrder;
					CellSize = UDim2.fromScale(0.15, 0.15);
					CellPadding = UDim2.fromScale(0.015, 0.015);
					[React.Change.AbsoluteContentSize] = function(ui)
						local scrollingDirection = props.frameProps and props.frameProps.ScrollingDirection or Enum.ScrollingDirection.XY
						local changeX = scrollingDirection == Enum.ScrollingDirection.XY or scrollingDirection == Enum.ScrollingDirection.X
						local changeY = scrollingDirection == Enum.ScrollingDirection.XY or scrollingDirection == Enum.ScrollingDirection.Y
						
						setCanvasSize(UDim2.new(0, changeX and ui.AbsoluteContentSize.X or 0, 0, changeY and ui.AbsoluteContentSize.Y + 10 or 0))
					end
				}, props.layoutProps or {}));

				Tiles = props.tiles;
			}, props.children or {});
		}, props.containerProps or {});
	})
end

return autoResizeScrollFrame