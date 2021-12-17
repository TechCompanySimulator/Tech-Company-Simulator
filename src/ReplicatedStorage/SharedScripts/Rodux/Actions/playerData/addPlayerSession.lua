local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addPlayerSession", function(userId, data)
	return {
		userId = userId,
		data = data,
	}
end)