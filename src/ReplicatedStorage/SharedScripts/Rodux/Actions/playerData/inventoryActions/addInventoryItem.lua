local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addInventoryItem", function(userId, inventoryName, category, variation, item, plotData)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		variation = variation,
		item = item,
		plotData = plotData
	}
end)