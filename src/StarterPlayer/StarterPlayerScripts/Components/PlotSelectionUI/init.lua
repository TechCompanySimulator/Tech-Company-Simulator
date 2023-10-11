local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")
local PlotSelection = loadModule("PlotSelection")

local setInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local template = RoactTemplate.fromInstance(React, ReplicatedStorage.UITemplates.PlotSelection.Holder)

local e = React.createElement
local useEffect = React.useEffect

local function plotSelection(props)
	useEffect(function()
		PlotSelection.initiateSelection()

		return function()
			print("Ending selection")
			PlotSelection.endSelection()
		end
	end, {})

	return props.visible and e(template, {
		Left = {
			[React.Event.MouseButton1Click] = function()
				PlotSelection.cycleLeft()
			end
		};

		Right = {
			[React.Event.MouseButton1Click] = function()
				PlotSelection.cycleRight()
			end
		};

		GoToPlot = {
			[React.Event.MouseButton1Click] = function()
				PlotSelection.goToCurrentPlot()
				setInterfaceState:Fire("gameplay")
				PlotSelection.endSelection()
			end
		};
	})
end

return plotSelection