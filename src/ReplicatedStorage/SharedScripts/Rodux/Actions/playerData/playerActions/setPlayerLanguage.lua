local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("setPlayerLanguage", function(player : Player, language : string) : ()
	return {
		userId = player.UserId;
		language = language;
	}
end)