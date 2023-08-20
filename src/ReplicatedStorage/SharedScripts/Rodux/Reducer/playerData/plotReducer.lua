local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

return {
	addPlotItem = function(state, action)
		local userId = action.userId
		local category = action.category
		local itemData = action.itemData

		if userId and category and itemData then
			local currentPlayerData = state[tostring(userId)] or {}
			local plotData = currentPlayerData.PlotData or {}
			local categoryData = plotData[category] or {}

			return Llama.Dictionary.join(state, {
				[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
					PlotData = Llama.Dictionary.join(plotData, {
						[category] = Llama.List.join(categoryData, {
							itemData;
						});
					});
				});
			})
		else
			return state
		end
	end;
}