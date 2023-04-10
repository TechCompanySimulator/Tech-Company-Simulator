local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local Rodux = loadModule("Rodux")

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

	setPlayerDataValue = function(state, action)
		local userId = action.userId
		local newIndex = action.newIndex
		local value = action.value

		if userId and newIndex and value then
			local currentData = state[tostring(userId)] or {}

			currentData = Llama.Dictionary.join(currentData, {
				[newIndex] = value;
			})

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = currentData;
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

			local uniqueId = 0
			for id in pairs(currentCategoryData) do
				uniqueId += 1

				if tonumber(id) ~= uniqueId then break end
			end

			local newInventory = Llama.Dictionary.join(currentInventory, {
				[category] = Llama.Dictionary.join(currentCategoryData, {
					[tostring(uniqueId)] = item;
				});
			})

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = newInventory;
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
})