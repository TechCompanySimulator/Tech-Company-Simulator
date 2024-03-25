local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("addOrb", function(userId, orbId)
	return {
		userId = userId;
		orbId = orbId;
	}
end)