local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("editMachineValues", function(machine, valueType, value)
	return {
		userId = machine.userId;
		guid = machine.guid;
		valueType = valueType;
		value = value;
	}
end)