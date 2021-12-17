local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("setPlayerLevel", function(userId, newLevel)
	return {
		userId = userId,
		newLevel = newLevel,
	}
end)