local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("updateOrb", function(userId, orbId, orbData)
	return {
		userId = userId;
		orbId = orbId;
		orbData = orbData;
	}
end)