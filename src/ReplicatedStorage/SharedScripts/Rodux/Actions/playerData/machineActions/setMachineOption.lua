local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("setMachineOption", function(machine, buildOption)
	return {
		userId = machine.userId;
		machine = machine;
		buildOption = buildOption;
	}
end)