local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local assets = ReplicatedStorage.Assets

local PlotUtility = {}

function PlotUtility.getItemConfig(category, variation, itemId)
	local shopConfig = RoduxStore:getState().gameValues.shopConfig
	if not shopConfig[category] or not shopConfig[category].variations[variation] or not shopConfig[category].variations[variation][itemId] then return end

	return shopConfig[category].variations[variation][itemId]
end

function PlotUtility.getAsset(category, variation, itemId)
	local categoryItems = assets:FindFirstChild(category)
	if not categoryItems then warn('No items found for category ' .. category) return end

	local variationItems = categoryItems:FindFirstChild(variation)
	if not variationItems then warn('No variations found for variation ' .. variation .. ' in category ' .. category) return end

	return variationItems:FindFirstChild(itemId)
end

return PlotUtility