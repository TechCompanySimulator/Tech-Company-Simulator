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
		local variation = action.variation
		local item = action.item

		if not userId or not inventoryName or not category or not variation or not item then return state end

		local currentData = state[tostring(userId)] or {}
		local currentInventory = currentData[inventoryName] or {}
		local currentCategoryData = currentInventory[category] or {}
		local currentVariationData = currentCategoryData[variation] or {}

		local key = getUniqueKey(currentCategoryData)

		-- Add the item to the inventory data
		local newInventoryData = Llama.Dictionary.join(currentInventory, {
			[category] = Llama.Dictionary.join(currentCategoryData, {
				[variation] = Llama.Dictionary.join(currentVariationData, {
					[key] = item;
				});
			});
		})

		-- If we pass in plot data, add it to the plot data with the same key
		local currentPlotData = currentData.PlotData or {}
		local newPlotData = currentPlotData
		if action.plotData then
			local plotCategoryData = currentPlotData[category] or {}
			local plotVariationData = plotCategoryData[variation] or {}

			newPlotData = Llama.Dictionary.join(currentPlotData, {
				[category] = Llama.Dictionary.join(plotCategoryData, {
					[variation] = Llama.Dictionary.join(plotVariationData, {
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
		local variation = action.variation
		local items = action.items

		if not userId or not inventoryName or not category or not variation or not items then return state end

		local currentData = state[tostring(userId)] or {}
		local currentInventory = currentData[inventoryName] or {}
		local currentCategoryData = currentInventory[category] or {}
		local currentVariationData = currentCategoryData[variation] or {}

		local newItems = table.clone(currentVariationData)
		for _, item in items do
			local key = getUniqueKey(newItems)
			newItems[key] = item
		end

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				[inventoryName] = Llama.Dictionary.join(currentInventory, {
					[category] = Llama.Dictionary.join(currentCategoryData, {
						[variation] = newItems
					});
				});
			});
		})
	end;

	changeInventoryItem = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local variation = action.variation
		local key = action.key
		local newValues = action.newValues

		if not userId or not inventoryName or not category or not variation or not key or not newValues then return state end

		local currentData = state[tostring(userId)] or {}
		local currentInventory = currentData[inventoryName] or {}
		local currentCategoryData = currentInventory[category] or {}
		local currentVariationData = currentCategoryData[variation] or {}
		local currentItemData = currentVariationData[key]

		if not currentItemData then return state end

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				[inventoryName] = Llama.Dictionary.join(currentInventory, {
					[category] = Llama.Dictionary.join(currentCategoryData, {
						[variation] = Llama.Dictionary.join(currentVariationData, {
							[key] = Llama.Dictionary.join(currentItemData, newValues);
						})
					});
				});
			});
		})
	end;

	-- REmoves from plot as well
	removeInventoryItem = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local variation = action.variation
		local key = action.key

		if not userId or not inventoryName or not category or not variation or not key then return state end

		local currentData = state[tostring(userId)] or {}
		local currentInventory = currentData[inventoryName] or {}
		local currentCategoryData = currentInventory[category] or {}
		local currentVariationData = currentCategoryData[variation] or {}

		local currentPlotData = currentData.PlotData or {}
		local currentPlotCategoryData = currentPlotData[category] or {}
		local currentPlotVariationData = currentPlotCategoryData[variation] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				[inventoryName] = Llama.Dictionary.join(currentInventory, {
					[category] = Llama.Dictionary.join(currentCategoryData, {
						[variation] = Llama.Dictionary.join(currentVariationData, {
							[key] = Llama.None;
						});
					});
				});

				PlotData = Llama.Dictionary.join(currentPlotData, {
					[category] = Llama.Dictionary.join(currentPlotCategoryData, {
						[variation] = Llama.Dictionary.join(currentPlotVariationData, {
							[key] = Llama.None;
						});
					});
				});
			});
		})
	end;

	removeMultipleInvItems = function(state, action)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local variation = action.variation
		local keys = action.keys

		if not userId or not inventoryName or not category or not variation or not keys then return state end

		local currentData = state[tostring(userId)] or {}
		local currentInventory = currentData[inventoryName] or {}
		local currentCategoryData = currentInventory[category] or {}
		local currentVariationData = currentCategoryData[variation] or {}

		local currentPlotData = currentData.PlotData or {}
		local currentPlotCategoryData = currentPlotData[category] or {}
		local currentPlotVariationData = currentPlotCategoryData[variation] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentData, {
				[inventoryName] = Llama.Dictionary.join(currentInventory, {
					[category] = Llama.Dictionary.join(currentCategoryData, {
						[variation] = Llama.Dictionary.join(currentVariationData, Llama.Dictionary.map(keys, function(key, _)
							return Llama.None, key
						end));
					});
				});

				PlotData = Llama.Dictionary.join(currentPlotData, {
					[category] = Llama.Dictionary.join(currentPlotCategoryData, {
						[variation] = Llama.Dictionary.join(currentPlotVariationData, Llama.Dictionary.map(keys, function(key, _)
							return Llama.None, key
						end));
					});
				});
			});
		})
	end;
}