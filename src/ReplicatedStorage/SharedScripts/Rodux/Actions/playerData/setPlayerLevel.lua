local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("setPlayerLevel", function(userId, newLevel)
	return {
		userId = userId,
		newLevel = newLevel,
	}
end)