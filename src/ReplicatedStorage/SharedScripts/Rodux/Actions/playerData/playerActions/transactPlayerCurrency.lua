local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("transactPlayerCurrency", function(player : Player, currency : string, amount : number)
	return {
		userId = player.UserId;
		currency = currency;
		amount = amount;
	}
end)