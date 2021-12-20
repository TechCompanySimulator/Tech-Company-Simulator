local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("removeInventoryItem", function(userId, category, item)
	return {
		userId = userId,
		category = category,
		item = item
	}
end)