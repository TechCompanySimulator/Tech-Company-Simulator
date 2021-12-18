local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("setMachineAutomation", function(userId, machine, isEnabled)
	return {
		userId = userId;
		guid = machine.guid;
		automationEnabled = isEnabled;
	}
end)