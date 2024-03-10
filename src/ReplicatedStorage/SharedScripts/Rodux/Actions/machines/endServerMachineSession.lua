local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("endServerMachineSession", function(userId: number): table
	return {
		userId = userId;
	}
end)