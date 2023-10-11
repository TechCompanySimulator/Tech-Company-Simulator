local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local currentIndex = 1

local PlotSelection = {}
PlotSelection.freePlots = {}

function PlotSelection.initiate()
	for _, plotPart in workspace.Plots:GetChildren() do
		table.insert(PlotSelection.freePlots, plotPart)
		plotPart:GetAttributeChangedSignal("Taken", function()
			PlotSelection.takenAttributeChanged(plotPart)
		end)
	end
end

function PlotSelection.initiateSelection()
	camera.CameraType = Enum.CameraType.Scriptable
	for _, plot in PlotSelection.freePlots do
		camera.CFrame = CFrame.lookAt((plot.CFrame * CFrame.new(0, 15, plot.Size.Z).Position), plot.Position)
	end
end

function PlotSelection.cycleLeft()
	currentIndex -= 1
	if currentIndex <= 0 then
		currentIndex = #PlotSelection.freePlots
	end

	local newPlotPart = PlotSelection.freePlots[currentIndex]
	camera.CFrame = CFrame.lookAt((newPlotPart.CFrame * CFrame.new(0, 15, newPlotPart.Size.Z).Position), newPlotPart.Position)
end

function PlotSelection.cycleRight()
	currentIndex += 1
	if currentIndex > #PlotSelection.freePlots then
		currentIndex = 1
	end

	local newPlotPart = PlotSelection.freePlots[currentIndex]
	camera.CFrame = CFrame.lookAt((newPlotPart.CFrame * CFrame.new(0, 15, newPlotPart.Size.Z).Position), newPlotPart.Position)
end

function PlotSelection.goToCurrentPlot()
	local currentPlot = PlotSelection.freePlots[currentIndex]
	if not currentPlot then return end

	local character = player.Character
	if not character then return end

	local plotNum = tonumber(string.sub(currentPlot.Name, 5))
	local spawn = workspace.Spawns:FindFirstChild("Spawn" .. tostring(plotNum))
	character:MoveTo(spawn.Position)
end

function PlotSelection.endSelection()
	camera.CameraType = Enum.CameraType.Custom
end

function PlotSelection.takenAttributeChanged(plotPart)
	if plotPart:GetAttribute("Taken") then
		local index = table.find(PlotSelection.freePlots, plotPart)
		if index then
			table.remove(PlotSelection.freePlots, index)
		end
	else
		table.insert(PlotSelection.freePlots, plotPart)
	end
end

return PlotSelection