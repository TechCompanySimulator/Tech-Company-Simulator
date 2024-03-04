local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("removeServerMachine", function(userId: number, machineGuid: string): table
	return {
		userId = userId;
		guid = machineGuid;
	}
end)