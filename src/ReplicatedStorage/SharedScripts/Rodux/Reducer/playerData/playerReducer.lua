local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

return {
	setPlayerSession = function(state, action)
		local userId = action.userId

		if userId then
			return Llama.Dictionary.join(state, {
				[tostring(userId)] = action.data;
			})
		else
			return state
		end
	end;

	transactPlayerCurrency = function(state, action)
		local userId = action.userId
		local currency = action.currency
		local amount = action.amount

		if userId and currency and amount then
			local currentPlayerData = state[tostring(userId)] or {}
			local currentAmount = currentPlayerData.Currencies[currency]

			-- If the currency doesn't exist, then return the current state
			if not currentAmount then
				return state
			end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
					Currencies = Llama.Dictionary.join(currentPlayerData.Currencies, {
						[currency] = math.max(currentAmount + amount, 0);
					});
				});
			})
		else
			return state
		end
	end;

	setPlayerCurrency = function(state, action)
		local userId = action.userId
		local currency = action.currency
		local amount = action.amount

		if userId and currency and amount then
			local currentPlayerData = state[tostring(userId)] or {}
			local currentAmount = currentPlayerData.Currencies[currency]

			-- If the currency doesn't exist, then return the current state
			if not currentAmount then
				return state
			end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
					Currencies = Llama.Dictionary.join(currentPlayerData.Currencies, {
						[currency] = math.max(amount, 0);
					});
				});
			})
		else
			return state
		end
	end;

	updateDailyRewards = function(state, action)
		local userId = action.userId

		if userId then
			local currentData = state[tostring(userId)] or {}
			local currentDailyRewards = currentData.DailyRewards or {}

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(state[tostring(userId)], {
					DailyRewards = Llama.Dictionary.join(currentDailyRewards, {
						timeBoundary = action.timeBoundary;
						loginTime = action.loginTime;
						streak = action.streak;
					});
				});
			})
		else
			return state
		end
	end;
}