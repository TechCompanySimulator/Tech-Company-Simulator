local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

return {
	setPlayerSession = function(state, action)
		local userId = action.userId
		if not userId then return state end

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = action.data;
		})
	end;

	transactPlayerCurrency = function(state, action)
		local userId = action.userId
		local currency = action.currency
		local amount = action.amount

		if userId and currency and amount then
			local currentPlayerData = state[tostring(userId)] or {}
			local currentCurrencies = currentPlayerData.Currencies or {}
			local currentAmount = currentPlayerData.Currencies[currency]

			-- If the currency doesn't exist, then return the current state
			if not currentAmount then
				return state
			end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
					Currencies = Llama.Dictionary.join(currentCurrencies, {
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
			local currentCurrencies = currentPlayerData.Currencies or {}
			local currentAmount = currentPlayerData.Currencies[currency]

			-- If the currency doesn't exist, then return the current state
			if not currentAmount then
				return state
			end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
					Currencies = Llama.Dictionary.join(currentCurrencies, {
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
		if not userId then return state end

		local currentData = state[tostring(userId)] or {}
		local currentDailyRewards = currentData.DailyRewards or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				DailyRewards = Llama.Dictionary.join(currentDailyRewards, {
					timeBoundary = action.timeBoundary;
					loginTime = action.loginTime;
					streak = action.streak;
				});
			});
		})
	end;

	setPlayerLanguage = function(state, action)
		local userId = action.userId
		if not userId then return state end

		local currentData = state[tostring(userId)] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				Language = action.language;
			});
		})
	end;

	changePlayerSetting = function(state, action)
		local userId = action.userId
		if not userId then return state end

		local currentData = state[tostring(userId)] or {}
		local currentSettings = currentData.Settings or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				Settings = Llama.Dictionary.join(currentSettings, {
					[action.setting] = action.value;
				});
			});
		})
	end;
}