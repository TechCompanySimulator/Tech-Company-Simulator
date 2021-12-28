local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("changeInventoryItem", function(userId, inventoryName, category, item, newItem)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		item = item,
		newItem = newItem
	}
end)