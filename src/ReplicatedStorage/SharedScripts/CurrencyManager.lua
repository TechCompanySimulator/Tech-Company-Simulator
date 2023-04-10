local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local RoduxStore = loadModule("RoduxStore")
local transactPlayerCurrency = loadModule("transactPlayerCurrency")

local VALID_CURRENCIES = {
	"Coins";
	"Gems";
}

local CurrencyManager = {}

function CurrencyManager:isValidCurrency(currency : string) : boolean
	return table.find(VALID_CURRENCIES, currency) ~= nil
end

function CurrencyManager:getBalance(player : Player, currency : string) : number
	if not CurrencyManager:isValidCurrency(currency) then
		warn("Invalid currency: " .. currency)
		return
	end

	local playerCurrency = RoduxStore:waitForValue("playerData", tostring(player.UserId), currency)

	return playerCurrency
end

function CurrencyManager:hasAmount(player : Player, currency : string, amount : number) : boolean
	local playerBalance = CurrencyManager:getBalance(player, currency)

	if playerBalance then
		return playerBalance >= amount
	else
		warn("Error getting player balance for currency: " .. currency)
	end

	return false
end

if RunService:IsServer() then
	function CurrencyManager:transact(player : Player, currency : string, amount : number) : boolean
		if not CurrencyManager:isValidCurrency(currency) then
			warn("Invalid currency: " .. currency)
			return false
		end

		local isExpense = math.sign(amount) == -1

		if isExpense and not CurrencyManager:hasAmount(player, currency, math.abs(amount)) then
			return false
		else
			RoduxStore:dispatch(transactPlayerCurrency(player, currency, amount))

			return true
		end
	end
end

return CurrencyManager