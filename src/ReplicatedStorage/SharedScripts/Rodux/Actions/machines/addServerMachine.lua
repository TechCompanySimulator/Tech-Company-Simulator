local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("addServerMachine", function(userId: number, machineData: table): table
	return {
		userId = userId;
		machineData = machineData;
	}
end)