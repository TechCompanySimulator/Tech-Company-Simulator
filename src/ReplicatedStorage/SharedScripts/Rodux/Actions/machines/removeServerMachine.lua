local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("removeServerMachine", function(userId : number, machine : table) : table
	return {
		userId = userId;
		machineData = machine;
	}
end)