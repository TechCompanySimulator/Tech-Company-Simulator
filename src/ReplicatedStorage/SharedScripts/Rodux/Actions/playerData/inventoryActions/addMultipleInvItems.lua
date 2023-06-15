local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addMultipleInvItems", function(userId, inventoryName, category, items)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		items = items
	}
end)