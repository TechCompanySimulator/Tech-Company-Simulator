local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("setMachineLevel", function(userId, machine, buildOption)
	return {
		userId = userId;
		guid = machine.guid;
		buildOption = buildOption;
	}
end)