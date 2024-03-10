local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")
local Mouse = loadModule("Mouse")
local PlotSelection = loadModule("PlotSelection")
local InstanceUtil = loadModule("InstanceUtil")

local setInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")
local deleteItemEvent = getDataStream("DeleteItem", "RemoteEvent")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local deleteModeMaid = Maid.new()

local BuildModeSystem = {}
BuildModeSystem.isActive = false

function BuildModeSystem.enter()
	if BuildModeSystem.isActive then return end

	BuildModeSystem.isActive = true
	--Camera:setCameraType("BuildMode", workspace.Plots.Plot1.CFrame + Vector3.new(0, 2, 0), workspace.Plots.Plot1.Size.X)
	setInterfaceState:Fire("buildMode")
end

function BuildModeSystem.exit()
	if not BuildModeSystem.isActive then return end
	
	BuildModeSystem.isActive = false
	BuildModeSystem.deleteModeActive = false
	deleteModeMaid:DoCleaning()
	--Camera:setCameraType("Default")
	setInterfaceState:Fire("gameplay")
end

function BuildModeSystem.toggleDeleteMode(isActive)
	if isActive == nil then
		isActive = not BuildModeSystem.deleteModeActive
	end

	BuildModeSystem.deleteModeActive = isActive

	if isActive then
		local plotPart = PlotSelection.myPlot
		if not plotPart then return end
		
		local highlightedModel

		local function removeHighlightedModel()
			if not highlightedModel then return end

			InstanceUtil.toggleModelCol(highlightedModel, nil, false)
			highlightedModel = nil
		end
		
		deleteModeMaid:GiveTask(RunService.RenderStepped:Connect(function()
			local placedItemsFolder = workspace.PlacedItems:FindFirstChild(plotPart.Name)
			if not placedItemsFolder then return end

			local hit = Mouse.findHitWithWhitelist(mouse, {
				placedItemsFolder;
			}, 100)
	
			if not hit or not hit.Instance then 
				removeHighlightedModel()

				return 
			end
				
			local itemModel = InstanceUtil.findFirstAncestorUnderInstance(hit.Instance, placedItemsFolder)
			if not itemModel then 
				removeHighlightedModel()

				return 
			end

			if highlightedModel == itemModel then return end

			if highlightedModel then
				InstanceUtil.toggleModelCol(highlightedModel, nil, false)
			end

			InstanceUtil.toggleModelCol(itemModel, Color3.new(1, 0, 0), true)
			highlightedModel = itemModel
		end))

		deleteModeMaid:GiveTask(UserInputService.InputEnded:Connect(function(input, processed)
			if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 or not highlightedModel then return end

			deleteItemEvent:FireServer(plotPart.Name, highlightedModel)
			highlightedModel:Destroy()
			removeHighlightedModel()
		end))
	else
		deleteModeMaid:DoCleaning()
	end
end

return BuildModeSystem