local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("removePlotItem", function(userId : Player, category : string, variation : string, itemIndex : string)
	return {
		userId = userId;
		category = category;
		variation = variation;
		itemIndex = itemIndex;
	}
end)