local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("setPlayerLanguage", function(userId : Player, language : string) : table
	return {
		userId = userId;
		language = language;
	}
end)