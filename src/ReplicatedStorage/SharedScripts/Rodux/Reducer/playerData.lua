local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local Rodux = loadModule("Rodux")

local function getUniqueKey(itemTable)
	local largestValue = 0
	for key, _ in pairs(itemTable) do
		local number = string.gsub(key, "%D", "")
		number = tonumber(number)

		if number and number > largestValue then
			largestValue = number
		end
	end

	return "key_" .. (largestValue + 1)
end

return Rodux.createReducer({}, {
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

	addInventoryItem = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local item = action.item

		if userId and inventoryName and category and item then
			local currentData = state[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}

			local key = getUniqueKey(currentCategoryData)

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = Llama.Dictionary.join(currentInventory, {
						[category] = Llama.Dictionary.join(currentCategoryData, {
							[key] = item;
						});
					});
				});
			})
		else
			return state
		end
	end;

	addMultipleInvItems = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local items = action.items

		if userId and inventoryName and category and items then
			local currentData = state[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}

			local newItems = table.clone(currentCategoryData)
			for _, item in items do
				local key = getUniqueKey(currentCategoryData)
				newItems[key] = item
			end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = Llama.Dictionary.join(currentInventory, {
						[category] = newItems;
					});
				});
			})
		else
			return state
		end
	end;

	changeInventoryItem = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local item = action.item
		local newItem = action.newItem

		if userId and inventoryName and category and item and newItem then
			local currentData = state[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}

			local changeId
			for id, invItem in pairs(currentCategoryData) do
				if Llama.deepCheckEquality(item, invItem) then
					changeId = id
					break
				end
			end

			if not changeId then return state end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = Llama.Dictionary.join(currentInventory, {
						[category] = Llama.Dictionary.join(currentCategoryData, {
							[tostring(changeId)] = newItem;
						});
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
})