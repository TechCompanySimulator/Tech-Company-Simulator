local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("changeInventoryItem", function(userId, category, item, newItem)
	return {
		userId = userId,
		category = category,
		item = item,
		newItem = newItem
	}
end)