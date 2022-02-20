local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local setPlayerData = loadModule("setPlayerData")

local CurrencyManager = {}

-- Adds the amount of currency the players currency saved in their data
function CurrencyManager:transact(player, currency, amount)
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	local currentAmount = playerData[currency] or 0
	local canTransact = amount >= 0 or CurrencyManager.hasEnoughCurrency(player, currency, amount)
	if canTransact then
		RoduxStore:dispatch(setPlayerData(player.UserId, currency, currentAmount + amount))
		return true
	end
end

-- Returns the amount of the given currency the player has
function CurrencyManager.getCurrencyAmount(player, currency)
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	return playerData[currency]
end

-- Returns true or false depending on if they have enough of the given currency or not
function CurrencyManager.hasEnoughCurrency(player, currency, amount)
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	return typeof(playerData[currency]) == "number" and playerData[currency] >= amount
end

return CurrencyManager