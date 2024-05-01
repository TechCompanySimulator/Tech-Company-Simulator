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

		if not userId or not inventoryName or not category or not item then return state end

		local currentData = state[tostring(userId)] or {}
		local currentInventory = currentData[inventoryName] or {}
		local currentCategoryData = currentInventory[category] or {}

		local key = getUniqueKey(currentCategoryData)

		-- Add the item to the inventory data
		local newInventoryData = Llama.Dictionary.join(currentInventory, {
			[category] = Llama.Dictionary.join(currentCategoryData, {
				[key] = item;
			});
		})

		-- If we pass in plot data, add it to the plot data with the same key
		local currentPlotData = currentData.PlotData or {}
		local newPlotData = currentPlotData
		if action.plotData then
			local plotCategoryData = currentPlotData[category] or {}
			local plotVariationData = plotCategoryData[variation] or {}

			newPlotData = Llama.Dictionary.join(currentPlotData, {
				[category] = Llama.Dictionary.join(categoryData, {
					[variation] = Llama.Dictionary.join(variationData, {
						[key] = action.plotData;
					})
				});
			});
		end

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				[inventoryName] = newInventoryData;

				PlotData = newPlotData;
			});
		})
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
				local key = getUniqueKey(newItems)
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
		local newValues = action.newValues

		if userId and inventoryName and category and key and newValues then
			local currentData = state[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}
			local currentItemData = currentCategoryData[key]

			if not currentItemData then return state end

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = Llama.Dictionary.join(currentInventory, {
						[category] = Llama.Dictionary.join(currentCategoryData, {
							[key] = Llama.Dictionary.join(currentItemData, newValues);
						});
					});
				});
			})
		else
			return state
		end
	end;

	-- REmoves from plot as well
	removeInventoryItem = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local key = action.key

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

	removeMultipleInvItems = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local keys = action.keys

		if userId and inventoryName and category and keys then
			local currentData = state[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentData, {
					[inventoryName] = Llama.Dictionary.join(currentInventory, {
						[category] = Llama.Dictionary.join(currentCategoryData, Llama.Dictionary.map(keys, function(key, _)
							return Llama.None, key
						end));
					});
				});
			})
		else
			return state
		end
	end;
}