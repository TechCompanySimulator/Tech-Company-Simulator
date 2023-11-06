local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

return {
	addPlotItem = function(state, action)
		local userId = action.userId
		local category = action.category
		local itemIndex = action.itemIndex
		local itemData = action.itemData

		local currentPlayerData = state[tostring(userId)] or {}
		local plotData = currentPlayerData.PlotData or {}
		local categoryData = plotData[category] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
				PlotData = Llama.Dictionary.join(plotData, {
					[category] = Llama.Dictionary.join(categoryData, {
						[itemIndex] = itemData;
					});
				});
			});
		})
	end;

	removePlotItem = function(state, action)
		local userId = action.userId
		local category = action.category
		local itemIndex = action.itemIndex

		local currentPlayerData = state[tostring(userId)] or {}
		local plotData = currentPlayerData.PlotData or {}
		local categoryData = plotData[category] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
				PlotData = Llama.Dictionary.join(plotData, {
					[category] = Llama.Dictionary.join(categoryData, {
						[itemIndex] = Llama.None;
					});
				});
			});
		})
	end;
}