local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("removeMachine", function(userId, machine)
	return {
		userId = userId;
		guid = machine.guid;
	}
end)