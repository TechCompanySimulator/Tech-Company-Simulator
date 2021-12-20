local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local Table = loadModule("Table")

local addInventoryItem = loadModule("addInventoryItem")
local removeInventoryItem = loadModule("removeInventoryItem")
local changeInventoryItem = loadModule("changeInventoryItem")

local InventoryManager = {}

local BASE_INVENTORY_CAPACITY = 5

-- Returns the inventory table to be read from
function InventoryManager.getInventory(userId)
	local playerData = RoduxStore:getState().playerData[tostring(userId)]
	return playerData and playerData.Inventory or {}
end

-- Returns the number of items in the inventory
function InventoryManager.getContentSize(userId)
	local inventory = RoduxStore:getState().playerData[tostring(userId)].Inventory or {}
	return Table.length(inventory)
end

-- Returns the current max amount of items the player can have in their inventory
function InventoryManager.getCapacity(userId)
	local playerData = RoduxStore:getState().playerData[tostring(userId)]
	return (playerData and playerData.InvCapacity) or BASE_INVENTORY_CAPACITY
end

-- Returns whether the players inventory is full or not
function InventoryManager.isInventoryFull(userId)
	if InventoryManager.getContentSize(userId) >= InventoryManager.getCapacity(userId) then return true end
	return false
end

-- Returns a boolean of whether the player has the item in their inventory
function InventoryManager.hasItem(userId, category, item)
	for _, invItem in pairs(InventoryManager.getInventory(userId)[category] or {}) do
		if Table.deepCheckEquality(item, invItem) then
			return true
		end
	end
	return false
end

-- Returns the number of matches in the inventory for the given item
function InventoryManager.getItemCount(userId, category, item)
	local itemCount = 0
	for _, invItem in pairs(InventoryManager.getInventory(userId)[category] or {}) do
		if Table.deepCheckEquality(item, invItem) then
			itemCount += 1
		end
	end
	return itemCount
end

if RunService:IsServer() then
	-- Adds an item to the players inventory, returning a boolean of whether it succeeded or not
	function InventoryManager.addItem(userId, category, item)
		if InventoryManager.isInventoryFull(userId) then return false end
		RoduxStore:dispatch(addInventoryItem(userId, category, item))
		return true
	end

	-- Adds an item to the players inventory, returning a boolean of whether it succeeded or not
	function InventoryManager.removeItem(userId, category, item)
		if not InventoryManager.hasItem(userId, category, item) then return false end
		RoduxStore:dispatch(removeInventoryItem(userId, category, item))
		return true
	end

	-- Replaces an item in the inventory with the new item table (can be used for upgrading items etc)
	function InventoryManager.replaceItem(userId, category, item, newItem)
		if not InventoryManager.hasItem(userId, category, item) then return false end
		RoduxStore:dispatch(changeInventoryItem(userId, category, item, newItem))
		return true
	end
end

return InventoryManager