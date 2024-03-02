local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("completeResearch", function(userId : number, machineType : string, level : number) : table
	return {
		userId = userId;
		machineType = machineType;
		researchLevel = level;
	}
end)