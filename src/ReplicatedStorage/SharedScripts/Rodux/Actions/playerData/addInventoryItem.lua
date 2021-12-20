local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addInventoryItem", function(userId, inventoryName, category, item)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		item = item
	}
end)