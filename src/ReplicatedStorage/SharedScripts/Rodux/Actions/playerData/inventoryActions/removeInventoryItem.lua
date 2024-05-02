local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("removeInventoryItem", function(userId, inventoryName, category, variation, key)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		variation = variation,
		key = key
	}
end)