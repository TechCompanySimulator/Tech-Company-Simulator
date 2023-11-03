local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("changePlayerSetting", function(userId : number, setting : string, value : any) : table
	return {
		userId = userId;
		setting = setting;
		value = value;
	}
end)