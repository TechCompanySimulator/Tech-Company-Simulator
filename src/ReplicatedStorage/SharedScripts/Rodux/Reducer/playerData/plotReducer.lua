local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

return {
	addPlotItem = function(state, action)
		local userId = action.userId
		local category = action.category
		local variation = action.variation
		local itemData = action.itemData

		local currentPlayerData = state[tostring(userId)] or {}
		local plotData = currentPlayerData.PlotData or {}
		local categoryData = plotData[category] or {}
		local variationData = categoryData[variation] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
				PlotData = Llama.Dictionary.join(plotData, {
					[category] = Llama.Dictionary.join(categoryData, {
						[variation] = Llama.Dictionary.join(variationData, {
							itemData;
						})
					});
				});
			});
		})
	end;

	-- Only remove from plot not inventory
	removePlotItem = function(state, action)
		local userId = action.userId
		local category = action.category
		local variation = action.variation
		local itemIndex = action.itemIndex

		local currentPlayerData = state[tostring(userId)] or {}
		local plotData = currentPlayerData.PlotData or {}
		local categoryData = plotData[category] or {}
		local variationData = categoryData[variation] or {}

		local finalVariationData = table.clone(variationData)
		table.remove(finalVariationData, itemIndex)

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
				PlotData = Llama.Dictionary.join(plotData, {
					[category] = Llama.Dictionary.join(categoryData, {
						[variation] = finalVariationData;
					});
				});
			});
		})
	end;
}