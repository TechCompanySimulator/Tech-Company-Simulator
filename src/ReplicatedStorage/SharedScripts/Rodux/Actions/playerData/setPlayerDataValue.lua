local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("setPlayerDataValue", function(userId, newIndex, value)
	return {
		userId = userId,
		newIndex = newIndex,
		value = value
	}
end)