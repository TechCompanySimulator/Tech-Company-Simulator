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
	end;

	removePlayerSession = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			return Table.merge(newState, {
				[tostring(userId)] = Table.None
			})
		end
		return state
	end;

	addPlayerData = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		local newIndex = action.newIndex
		local value = action.value
		if userId and newIndex and value then
			local currentData = newState[tostring(userId)] or {}
			currentData[newIndex] = value

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;

	setPlayerLevel = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[tostring(userId)] or {}
			currentData.Level = action.newLevel

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end,

	addInventoryItem = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local item = action.item
		if userId and inventoryName and category and item then
			local currentData = newState[tostring(userId)] or {}
			local currentInventory = currentData.Inventory or {}
			local currentCategoryData = currentInventory[category] or {}

			local uniqueId = 1
			for id, _ in pairs(currentCategoryData) do
				if tonumber(id) ~= uniqueId then break end
				uniqueId += 1
			end

			local newInventory = Table.merge(currentInventory, {
				[category] = Table.merge(currentCategoryData, {
					[tostring(uniqueId)] = item
				})
			})

			currentData.Inventory = newInventory

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end,
	
	changeInventoryItem = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		local inventoryName = action.inventoryName
		local category = action.category
		local item = action.item
		local newItem = action.newItem
		if userId and inventoryName and category and item and newItem then
			local currentData = newState[tostring(userId)] or {}
			local currentInventory = currentData[inventoryName] or {}
			local currentCategoryData = currentInventory[category] or {}

			local changeId 
			for id, invItem in pairs(currentCategoryData) do
				if Table.deepCheckEquality(item, invItem) then 
					changeId = id
					break 
				end
			end

			if not changeId then return state end

			currentData.Inventory = Table.merge(currentInventory, {
				[category] = Table.merge(currentCategoryData, {
					[tostring(changeId)] = newItem
				})
			})

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;
})