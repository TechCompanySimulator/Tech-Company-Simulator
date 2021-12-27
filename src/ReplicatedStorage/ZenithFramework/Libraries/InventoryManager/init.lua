local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local Table = loadModule("Table")

local addInventoryItem = loadModule("addInventoryItem")
local changeInventoryItem = loadModule("changeInventoryItem")

local InventoryManager = {}

local BASE_INVENTORY_CAPACITY = 5

-- Returns the inventory table to be read from
function InventoryManager.getInventory(userId, inventoryName)
	local inventory = RoduxStore:waitForValue("playerData", tostring(userId), inventoryName or "Inventory")
	return inventory
end

-- Returns the number of items in the inventory
function InventoryManager.getContentSize(userId, inventoryName)
	return Table.length(InventoryManager.getInventory(userId, inventoryName))
end

-- Returns the current max amount of items the player can have in their inventory
function InventoryManager.getCapacity(userId, inventoryName)
	local playerData = RoduxStore:waitForValue("playerData", tostring(userId))
	return (playerData and playerData[(inventoryName or "Inventory") .. "Capacity"]) or BASE_INVENTORY_CAPACITY
end

-- Returns whether the players inventory is full or not
function InventoryManager.isInventoryFull(userId, inventoryName)
	if InventoryManager.getContentSize(userId, inventoryName) >= InventoryManager.getCapacity(userId, inventoryName) then return true end
	return false
end

-- Returns a boolean of whether the player has the item in their inventory
function InventoryManager.hasItem(userId, inventoryName, category, item)
	assert(typeof(category) == "string", "Category argument needs to be a string")
	assert(typeof(item) == "table", "Item argument needs to be a table")

	for _, invItem in pairs(InventoryManager.getInventory(userId, inventoryName)[category] or {}) do
		if Table.deepCheckEquality(item, invItem) then
			return true
		end
	end
	return false
end

-- Returns the number of matches in the inventory for the given item
function InventoryManager.getItemCount(userId, inventoryName, category, item)
	assert(typeof(category) == "string", "Category argument needs to be a string")
	assert(typeof(item) == "table", "Item argument needs to be a table")

	local itemCount = 0
	for _, invItem in pairs(InventoryManager.getInventory(userId, inventoryName)[category] or {}) do
		if Table.deepCheckEquality(item, invItem) then
			itemCount += 1
		end
	end
	return itemCount
end

if RunService:IsServer() then
	-- Adds an item to the players inventory, returning a boolean of whether it succeeded or not
	function InventoryManager.addItem(userId, inventoryName, category, item)
		if InventoryManager.isInventoryFull(userId, inventoryName) then return false end
		RoduxStore:dispatch(addInventoryItem(userId, inventoryName or "Inventory", category, item))
		return true
	end

	-- Removes an item from the players inventory, returning a boolean of whether it succeeded or not
	function InventoryManager.removeItem(userId, inventoryName, category, item)
		if not InventoryManager.hasItem(userId, inventoryName, category, item) then return false end
		RoduxStore:dispatch(changeInventoryItem(userId, inventoryName or "Inventory", category, item, Table.None))
		return true
	end

	-- Replaces an item in the inventory with the new item table (can be used for upgrading items etc)
	function InventoryManager.replaceItem(userId, inventoryName, category, item, newItem)
		if not InventoryManager.hasItem(userId, inventoryName, category, item) then return false end
		RoduxStore:dispatch(changeInventoryItem(userId, inventoryName or "Inventory", category, item, newItem))
		return true
	end
end

return InventoryManager