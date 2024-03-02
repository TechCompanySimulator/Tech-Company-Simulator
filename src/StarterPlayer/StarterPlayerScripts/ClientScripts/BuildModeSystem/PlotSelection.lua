local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local currentIndex = 1

local PlotSelection = {}
PlotSelection.freePlots = {}
PlotSelection.isSelecting = false

function PlotSelection.initiate()
	for _, plotPart in workspace.Plots:GetChildren() do
		table.insert(PlotSelection.freePlots, plotPart)
		plotPart:GetAttributeChangedSignal("Taken"):Connect(function()
			PlotSelection.takenAttributeChanged(plotPart)
		end)
	end
end

function PlotSelection.initiateSelection()
	PlotSelection.isSelecting = true
	camera.CameraType = Enum.CameraType.Scriptable
	local firstPlot = PlotSelection.freePlots[1]
	camera.CFrame = CFrame.lookAt((firstPlot.CFrame * CFrame.new(0, 15, firstPlot.Size.Z).Position), firstPlot.Position)
end

function PlotSelection.cycleLeft()
	currentIndex -= 1
	if currentIndex <= 0 then
		currentIndex = #PlotSelection.freePlots
	end

	PlotSelection.updateCam()
end

function PlotSelection.cycleRight()
	currentIndex += 1
	if currentIndex > #PlotSelection.freePlots then
		currentIndex = 1
	end

	PlotSelection.updateCam()
end

function PlotSelection.updateCam()
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
	PlotSelection.isSelecting = false
end

function PlotSelection.takenAttributeChanged(plotPart)
	if plotPart:GetAttribute("Taken") then
		local owner = plotPart:GetAttribute("Owner")
		if owner == player.UserId then
			PlotSelection.myPlot = plotPart
		end

		local index = table.find(PlotSelection.freePlots, plotPart)
		if index then
			table.remove(PlotSelection.freePlots, index)
			if PlotSelection.isSelecting and currentIndex == index then
				PlotSelection.cycleRight()
			end
		end
	else
		table.insert(PlotSelection.freePlots, plotPart)
	end
end

return PlotSelection