local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

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

return {
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
		local key = action.key
		local newItem = action.newItem

		if userId and inventoryName and category and key and newItem then
			local currentData = state[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}
			local currentItemData = currentCategoryData[key]

			if not currentItemData then return state end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = Llama.Dictionary.join(currentInventory, {
						[category] = Llama.Dictionary.join(currentCategoryData, {
							[key] = Llama.Dictionary.join(currentItemData, newItem);
						});
					});
				});
			})
		else
			return state
		end
	end;

	removeInventoryItem = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local key = action.item

		if userId and inventoryName and category and key then
			local currentData = state[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = Llama.Dictionary.join(currentInventory, {
						[category] = Llama.Dictionary.join(currentCategoryData, {
							[key] = Llama.None;
						});
					});
				});
			})
		else
			return state
		end
	end;
}