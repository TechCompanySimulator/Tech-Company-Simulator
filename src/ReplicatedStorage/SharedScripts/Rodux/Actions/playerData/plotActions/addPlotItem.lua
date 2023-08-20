local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addPlotItem", function(player : Player, category : string, itemData : table)
	return {
		userId = player.UserId;
		category = category;
		itemData = itemData;
	}
end)