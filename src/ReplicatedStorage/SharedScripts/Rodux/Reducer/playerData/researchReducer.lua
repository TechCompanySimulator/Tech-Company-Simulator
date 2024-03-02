local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")

return {
	incrementResearchProgress = function(state, action)
		local userId = action.userId
		local machineType = action.machineType
		local researchIndex = action.researchIndex

		if not userId or not machineType or not researchIndex then return state end

		local currentPlayerData = state[tostring(userId)] or {}
		local currentResearchLevels = currentPlayerData.ResearchLevels or {}
		local currentMachineResearch = currentResearchLevels[machineType] or {}
		local currentProgress = currentMachineResearch.Progress or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
				ResearchLevels = Llama.Dictionary.join(currentResearchLevels, {
					[machineType] = Llama.Dictionary.join(currentMachineResearch, {
						Progress = Llama.Dictionary.join(currentProgress, {
							[researchIndex] = true;
						});
					});
				});
			});
		})
	end;

	completeResearch = function(state, action)
		local userId = action.userId
		local machineType = action.machineType
		local level = action.researchLevel

		if not userId or not machineType or not level then return state end

		local currentPlayerData = state[tostring(userId)] or {}
		local currentResearchLevels = currentPlayerData.ResearchLevels or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentPlayerData, {
				ResearchLevels = Llama.Dictionary.join(currentResearchLevels, {
					[machineType] = {
						Level = level;
						Progress = {};
					};
				});
			});
		})
	end
}