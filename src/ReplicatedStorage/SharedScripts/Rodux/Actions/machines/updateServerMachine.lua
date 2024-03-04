local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("updateServerMachine", function(userId: number, guid: string, newMachineData: table): table
	return {
		userId = userId;
		guid = guid;
		newMachineData = newMachineData;
	}
end)