local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

return {
	addPlotItem = function(state, action)
		local userId = action.userId
		local category = action.category
		local variation = action.variation
		local key = action.key
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
							[key] = itemData;
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
		local key = action.key

		local currentPlayerData = state[tostring(userId)] or {}
		local plotData = currentPlayerData.PlotData or {}
		local categoryData = plotData[category] or {}
		local variationData = categoryData[variation] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
				PlotData = Llama.Dictionary.join(plotData, {
					[category] = Llama.Dictionary.join(categoryData, {
						[variation] = Llama.Dictionary.join(variationData, {
							[key] = Llama.None;
						});
					});
				});
			});
		})
	end;
}