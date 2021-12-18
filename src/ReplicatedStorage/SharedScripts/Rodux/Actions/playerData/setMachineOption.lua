local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("setMachineOption", function(userId, machine)
	return {
		userId = userId;
		guid = machine.guid;
		machine = machine;
	}
end)