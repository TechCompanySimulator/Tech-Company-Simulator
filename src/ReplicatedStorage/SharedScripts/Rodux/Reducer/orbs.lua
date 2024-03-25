local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local Rodux = loadModule("Rodux")

return Rodux.createReducer({}, {
	addOrb = function(state, action)
		local userId = action.userId
		local orbId = action.orbId

		local currentOrbs = state[tostring(userId)] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentOrbs, {
				[orbId] = {

				};
			});
		})
	end;

	removeOrb = function(state, action)
		local userId = action.userId
		local orbId = action.orbId

		local currentOrbs = state[tostring(userId)] or {}
		currentOrbs[orbId] = nil

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = currentOrbs;
		})
	end;

	updateOrb = function(state, action)
		local userId = action.userId
		local orbId = action.orbId
		local orbData = action.orbData

		local currentOrbs = state[tostring(userId)] or {}
		local currentOrb = currentOrbs[orbId] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentOrbs, {
				[orbId] = Llama.Dictionary.join(currentOrb, orbData);
			});
		})
	end;

	removePlayerOrbs = function(state, action)
		local userId = action.userId

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.None;
		})
	end;
})
