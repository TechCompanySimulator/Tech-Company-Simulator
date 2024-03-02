local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("incrementResearchProgress", function(userId : number, machineType : string, researchIndex : number) : table
	return {
		userId = userId;
		machineType = machineType;
		researchIndex = researchIndex;
	}
end)