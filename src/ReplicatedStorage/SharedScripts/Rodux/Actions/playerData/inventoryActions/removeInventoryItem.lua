local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("removeInventoryItem", function(userId, inventoryName, category, key)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		key = key
	}
end)