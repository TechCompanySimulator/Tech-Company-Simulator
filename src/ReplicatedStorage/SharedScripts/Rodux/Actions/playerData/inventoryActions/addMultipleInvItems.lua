local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addMultipleInvItems", function(userId, inventoryName, category, variation, items)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		variation = variation,
		items = items
	}
end)