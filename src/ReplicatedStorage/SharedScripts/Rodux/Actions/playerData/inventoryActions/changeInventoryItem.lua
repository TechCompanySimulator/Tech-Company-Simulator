local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("changeInventoryItem", function(userId, inventoryName, category, key, newValues)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		key = key,
		newValues = newValues
	}
end)