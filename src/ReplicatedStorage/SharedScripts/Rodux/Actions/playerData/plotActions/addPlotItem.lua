local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addPlotItem", function(userId : Player, category : string, itemData : table)
	return {
		userId = userId;
		category = category;
		itemData = itemData;
	}
end)