local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("changeInventoryItem", function(userId, inventoryName, category, variation, key, newValues)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		variation = variation,
		key = key,
		newValues = newValues
	}
end)