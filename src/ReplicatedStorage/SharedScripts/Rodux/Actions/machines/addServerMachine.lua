local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("addServerMachine", function(userId : number, machine : table) : table
	return {
		userId = userId;
		machine = machine;
	}
end)