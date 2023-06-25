local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("setMachineLevel", function(machine, upgradeType, upgradeLevel)
	return {
		userId = machine.userId;
		guid = machine.guid;
		upgradeType = upgradeType;
		upgradeLevel = upgradeLevel;
	}
end)