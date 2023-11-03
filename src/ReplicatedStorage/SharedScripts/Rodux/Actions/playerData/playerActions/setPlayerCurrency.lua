local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("setPlayerCurrency", function(userId : number, currency : string, amount : number) : table
	return {
		userId = userId;
		currency = currency;
		amount = amount;
	}
end)