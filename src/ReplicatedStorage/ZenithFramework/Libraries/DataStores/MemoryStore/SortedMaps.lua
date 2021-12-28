local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return {} end

local SortedMaps = {}

-- Created a memory store sorted map with the given name, and saves it in this module
function SortedMaps.getSortedMap(mapName)
	local sortedMap = (SortedMaps[mapName] and SortedMaps[mapName]) or MemoryStoreService:GetSortedMap(mapName)
	if not SortedMaps[mapName] then
		SortedMaps[mapName] = sortedMap
	end
	return sortedMap
end

-- Gets the lowest unique key to insert into the sorted map server list (strings as numbers with KEY_LENGTH digits e.g. 005440 would be the 5440th key)
function SortedMaps.getUniqueKey(map)
	local exclusiveLowerBound = nil
	local foundKey
	local isFirstKey = true
	local prevKey = 0
	while true do
		local success, items = pcall(function()
			return map:GetRangeAsync(Enum.SortDirection.Ascending, 100, exclusiveLowerBound)
		end)
		if success then
			for _, entry in ipairs(items) do
				isFirstKey = false
				if tonumber(entry.key) ~= prevKey + 1 then
					foundKey = prevKey + 1
					break
				end
				prevKey += 1
			end
			if #items < 100 then
				if not foundKey then
					foundKey = prevKey + 1
				end
				break
			end
			exclusiveLowerBound = items[#items].key
		end
		task.wait()
	end
	return foundKey, isFirstKey
end

-- Flushes all the memory out of a map
function SortedMaps.flush(map)
	local exclusiveLowerBound = nil
	while true do
		local items = map:GetRangeAsync(Enum.SortDirection.Ascending, 100, exclusiveLowerBound)
		local removedItems = false
		for _, entry in ipairs(items) do
			local success = pcall(function()
				map:RemoveAsync(entry.key)
			end)
			if success then 
				removedItems = true
			end
		end
		if #items < 100 and (removedItems or #items == 0) then break end
		if removedItems then
			exclusiveLowerBound = items[#items].key
		end
		task.wait()
	end
end

return SortedMaps