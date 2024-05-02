local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("removeMultipleInvItems", function(userId, inventoryName, category,  variation, keys)
	return {
		userId = userId,
		inventoryName = inventoryName,
		category = category,
		variation = variation,
		keys = keys
	}
end)