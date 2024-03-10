local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")
local PlayerDataManager = loadModule("PlayerDataManager")
local RoduxStore = loadModule("RoduxStore")
local CurrencyManager = loadModule("CurrencyManager")
local PlotUtility = loadModule("PlotUtility")
local Llama = loadModule("Llama")

local addPlotItem = loadModule("addPlotItem")
local removePlotItem = loadModule("removePlotItem")

local placeItemFunc = getDataStream("PlaceItem", "RemoteFunction")
local deleteItemEvent = getDataStream("DeleteItem", "RemoteEvent")

local assets = ReplicatedStorage.Assets
local maids = {}

local PlotSystem = {}
PlotSystem.playerPlotInfo = {}

function PlotSystem.initiate()
	for _, plot in workspace.Plots:GetChildren() do
		PlotSystem.setupPlotSign(plot)
	end

	Players.PlayerRemoving:Connect(PlotSystem.playerRemoving)

	placeItemFunc.OnServerInvoke = PlotSystem.placeItemRequest
	deleteItemEvent.OnServerEvent:Connect(function(player, plotName, item)
		PlotSystem.deleteItemRequest(player, plotName, item)
	end)
end

function PlotSystem.promptTriggered(player, plot)
	if plot:GetAttribute("Taken") or PlotSystem.playerPlotInfo[player] then return end

	plot:SetAttribute("Owner", player.UserId)
	plot:SetAttribute("Taken", true)
	maids[plot]:DoCleaning()
	plot:FindFirstChild("FreePlotSign"):Destroy()
	PlotSystem.playerPlotInfo[player] = plot

	PlotSystem.placePlotData(player, plot)
end

function PlotSystem.setupPlotSign(plot)
	plot:SetAttribute("Owner", nil)
	plot:SetAttribute("Taken", nil)
	local freePlotSign = assets.Misc.FreePlotSign:Clone()
	freePlotSign.Parent = plot
	local _, size = freePlotSign:GetBoundingBox()
	freePlotSign:PivotTo(plot.CFrame * CFrame.new(0, plot.Size.Y / 2 + size.Y / 2, plot.Size.Z / 2))

	maids[plot] = Maid.new()
	maids[plot]:GiveTask(freePlotSign.Main.ProximityPrompt.Triggered:Connect(function(player)
		PlotSystem.promptTriggered(player, plot)
	end))
end

function PlotSystem.placeItemRequest(player, category, variation, itemId, cfOffset)
	local plot = PlotSystem.playerPlotInfo[player]
	if not plot then return end

	local asset = PlotUtility.getAsset(category, variation, itemId)
	if not asset then return end

	local itemConfig = PlotUtility.getItemConfig(category:lower(), variation, itemId)
	if not itemConfig then return end
	
	local success = CurrencyManager:transact(player, itemConfig.price.currency, -itemConfig.price.amount)
	if not success then return end

	local placedItemsFolder = workspace.PlacedItems:FindFirstChild(plot.Name)
	if not placedItemsFolder then
		placedItemsFolder = Instance.new("Folder")
		placedItemsFolder.Name = plot.Name
		placedItemsFolder.Parent = workspace.PlacedItems
	end

	local assetClone = asset:Clone()
	assetClone.Parent = placedItemsFolder
	assetClone:PivotTo(plot.CFrame * cfOffset)

	local pos = cfOffset.Position
	local rotX, rotY, rotZ = cfOffset:ToOrientation()
	if math.abs(rotX) == 0 then
		rotX = ''
	else
		rotX = math.round(math.deg(rotX))
	end

	if math.abs(rotY) == 0 then
		rotY = ''
	else
		rotY = math.round(math.deg(rotY))
	end

	if math.abs(rotZ) == 0 then
		rotZ = ''
	else
		rotZ = math.round(math.deg(rotZ))
	end

	local posX = math.floor(pos.X * 1000) / 1000
	local posY = math.floor(pos.Y * 1000) / 1000
	local posZ = math.floor(pos.Z * 1000) / 1000

	local saveCf = posX .. "," .. posY .. "," .. posZ .. "," .. rotX .. "," .. rotY .. "," .. rotZ

	local playerData = RoduxStore:getState().playerData[tostring(player.UserId)]
	if not playerData then return end

	local changed = false
	local itemIndex = 1
	if playerData.PlotData and playerData.PlotData[category] and playerData.PlotData[category][variation] then
		local numItems = Llama.Dictionary.count(playerData.PlotData[category][variation])
		for i = 1, numItems do
			if playerData.PlotData[category][variation][tostring(i)] then continue end

			changed = true
			itemIndex = i
			break
		end

		if not changed then
			itemIndex = numItems + 1
		end
	end

	itemIndex = tostring(itemIndex)
	assetClone.Name = category .. "_" .. variation .. "_" .. itemId .. "_" .. itemIndex

	PlayerDataManager:updatePlayerData(player, addPlotItem, category, variation, itemIndex, {
		id = itemId;
		cf = saveCf;
	})

	return true
end

function PlotSystem.deleteItemRequest(player, plotName, item)
	if typeof(plotName) ~= "string" or typeof(item) ~= "Instance" then return end

	-- Sanity checks
	local plot = workspace.Plots:FindFirstChild(plotName)
	local placedItems = workspace.PlacedItems:FindFirstChild(plotName)
	if not plot 
		or plot:GetAttribute("Owner") ~= player.UserId 
		or not placedItems
		or not item:IsDescendantOf(placedItems) 
	then 
		return 
	end

	local splitName = string.split(item.Name, "_")
	local category, variation, _itemId, itemIndex = splitName[1], splitName[2], splitName[3], splitName[4]

	item:Destroy()
	PlayerDataManager:updatePlayerData(player, removePlotItem, category, variation, itemIndex)

	-- Give them a refund?
end

function PlotSystem.placePlotData(player, plot)
	local playerData = RoduxStore:getState().playerData[tostring(player.UserId)]
	if not playerData or not playerData.PlotData then return end

	local placedItemsFolder = workspace.PlacedItems:FindFirstChild(plot.Name)
	if not placedItemsFolder then
		placedItemsFolder = Instance.new("Folder")
		placedItemsFolder.Name = plot.Name
		placedItemsFolder.Parent = workspace.PlacedItems
	end

	local plotData = playerData.PlotData
	for category, categoryInfo in plotData do
		for variation, variationInfo in categoryInfo do
			for itemIndex, item in variationInfo do
				local asset = PlotUtility.getAsset(category, variation, item.id)
				if not asset then continue end

				local assetClone = asset:Clone()
				assetClone.Name = category .. "_" .. variation .. "_" .. item.id .. "_" .. itemIndex
				assetClone.Parent = placedItemsFolder
				local cfString = item.cf
				local split = string.split(cfString, ",")
				local pos = Vector3.new(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
				local cfOffset = CFrame.new(pos) * CFrame.Angles(math.rad(tonumber(split[4]) or 0), math.rad(tonumber(split[5]) or 0), math.rad(tonumber(split[6]) or 0))
				assetClone:PivotTo(PlotSystem.playerPlotInfo[player].CFrame * cfOffset)
			end
		end
	end
end

function PlotSystem.playerRemoving(player)
	if not PlotSystem.playerPlotInfo[player] then return end
	-- TODO: Clear plot and cleanup plots connections

	PlotSystem.setupPlotSign(PlotSystem.playerPlotInfo[player])
	PlotSystem.playerPlotInfo[player]:SetAttribute("Taken", false)
	PlotSystem.playerPlotInfo[player] = nil
end

return PlotSystem