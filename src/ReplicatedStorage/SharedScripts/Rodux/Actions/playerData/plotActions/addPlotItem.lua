local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addPlotItem", function(userId : Player, category : string, variation : string, key : string, itemData : table)
	return {
		userId = userId;
		category = category;
		variation = variation;
		key = key;
		itemData = itemData;
	}
end)