local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Rodux = loadModule("Rodux")
local Table = loadModule("Table")

return Rodux.createReducer({}, {
	addPlayerSession = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			return Table.merge(newState, {
				[tostring(userId)] = action.data
			})
		end
		return state
	end,

	removePlayerSession = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			return Table.merge(newState, {
				[tostring(userId)] = Table.None
			})
		end
		return state
	end,

	setPlayerLevel = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[userId] or {}

			return Table.merge(newState, {
				[tostring(userId)] = Table.merge(currentData, {
					Level = action.newLevel
				})
			})
		end
		return state
	end,
})