local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local RoduxStore = loadModule("RoduxStore")

local addInventoryItem = loadModule("addInventoryItem")
local addMultipleInvItems = loadModule("addMultipleInvItems")
local changeInventoryItem = loadModule("changeInventoryItem")
local removeInventoryItem = loadModule("removeInventoryItem")
local removeMultipleInvItems = loadModule("removeMultipleInvItems")

local InventoryManager = {}
InventoryManager.validCategories = {
	Tools = true;
}

function InventoryManager.isValidCategory(category)
	return InventoryManager.validCategories[category] ~= nil
end

-- Returns the inventory table to be read from
function InventoryManager.getInventory(userId, inventoryName)
	local inventory = RoduxStore:waitForValue("playerData", tostring(userId), inventoryName or "Inventory")

	return inventory
end

-- Returns the number of items in the inventory
function InventoryManager.getContentSize(userId, inventoryName, category)
	if not InventoryManager.isValidCategory(category) then return end

	return Llama.Dictionary.length(InventoryManager.getInventory(userId, inventoryName)[category] or {})
end

-- Returns the current max amount of items the player can have in their inventory
function InventoryManager.getCapacity(userId, inventoryName, category)
	if not InventoryManager.isValidCategory(category) then return 0 end

	local inventoryData = InventoryManager.getInventory(userId, inventoryName)
	if not inventoryData then return 0 end

	local capacitiesData = inventoryData.Capacities or {}
	local categoryCapacity = capacitiesData[category] or 0

	return categoryCapacity
end

-- Returns whether the players inventory is full or not, and how many more items can be added (0 when full)
function InventoryManager.isInventoryFull(userId, inventoryName, category)
	if not InventoryManager.isValidCategory(category) then return end

	local spacesLeft = InventoryManager.getCapacity(userId, inventoryName, category) - InventoryManager.getContentSize(userId, inventoryName, category)
	local isFull = spacesLeft <= 0
	return isFull, spacesLeft
end

function InventoryManager.getItem(userId, inventoryName, category, item)
	assert(typeof(category) == "string", "Category argument needs to be a string")
	assert(typeof(item) == "table", "Item argument needs to be a table")

	if not InventoryManager.isValidCategory(category) then return end

	for key, invItem in pairs(InventoryManager.getInventory(userId, inventoryName)[category] or {}) do
		if not Llama.deepCheckEquality(item, invItem) then continue end

		return key, invItem
	end

	return false
end

-- Returns a boolean of whether the player has the item in their inventory
function InventoryManager.hasItem(userId, inventoryName, category, item)
	return InventoryManager.getItem(userId, inventoryName, category, item) ~= false
end

-- Returns the number of matches in the inventory for the given item
function InventoryManager.getItemCount(userId, inventoryName, category, item)
	assert(typeof(category) == "string", "Category argument needs to be a string")
	assert(typeof(item) == "table", "Item argument needs to be a table")
	
	if not InventoryManager.isValidCategory(category) then return end

	local itemCount = 0

	for _, invItem in pairs(InventoryManager.getInventory(userId, inventoryName)[category] or {}) do
		if not Llama.deepCheckEquality(item, invItem) then continue end

		itemCount += 1
	end

	return itemCount
end

if RunService:IsServer() then
	-- Adds an item to the players inventory, returning a boolean of whether it succeeded or not
	function InventoryManager.addItem(userId, inventoryName, category, item)
		if InventoryManager.isInventoryFull(userId, inventoryName, category) == true then return false end

		RoduxStore:dispatch(addInventoryItem(userId, inventoryName or "Inventory", category, item))

		return true
	end

	-- Adds multiple items to the players inventory, returning a boolean of whether it succeeded or not (will not exceed the capacity)
	function InventoryManager.addMultipleItems(userId, inventoryName, category, items)
		local isFull, spacesLeft = InventoryManager.isInventoryFull(userId, inventoryName, category)
		if isFull then return false end

		local numItems = 0
		local itemsToAdd = {}
		for _, item in items do
			numItems += 1
			table.insert(itemsToAdd, item)
			if numItems >= spacesLeft then break end
		end

		RoduxStore:dispatch(addMultipleInvItems(userId, inventoryName or "Inventory", category, itemsToAdd))

		return true
	end

	-- Removes an item from the players inventory, returning a boolean of whether it succeeded or not
	function InventoryManager.removeItem(userId, inventoryName, category, key)
		if not InventoryManager.isValidCategory(category) then return false end

		RoduxStore:dispatch(removeInventoryItem(userId, inventoryName or "Inventory", category, key))

		return true
	end

	-- Removes multiple items, but only updates the Rodux store once to prevent unnecessary re-renders
	-- Keys is a list of keys to remove e.g. '{"key_3", "key_10", "key_15"}'
	function InventoryManager.removeMultipleInvItems(userId, inventoryName, category, keys)
		if not InventoryManager.isValidCategory(category) then return end

		RoduxStore:dispatch(removeMultipleInvItems(userId, inventoryName or "Inventory", category, keys))
	end

	-- Updates an item in the inventory with the new item table (can be used for upgrading items etc)
	function InventoryManager.updateItem(userId, inventoryName, category, key, newValues)
		if not InventoryManager.isValidCategory(category) then return false end

		local categoryData = InventoryManager.getInventory(userId, inventoryName)[category]
		if not categoryData or not categoryData[key] then return false end

		RoduxStore:dispatch(changeInventoryItem(userId, inventoryName or "Inventory", category, key, newValues))

		return true
	end
end

return InventoryManager