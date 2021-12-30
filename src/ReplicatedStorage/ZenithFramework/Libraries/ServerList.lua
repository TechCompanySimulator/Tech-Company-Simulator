local TestService = game:GetService("TestService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return {} end

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local SortedMaps = loadModule("SortedMaps")

local ServerList = {}

local SAVE_SERVER_LIST = true
local SERVER_KEY_LENGTH = 6
local SERVER_KEY_LIFETIME = 2592000

-- Creates a string number to represent the server in the sorted map server list
function ServerList.createServerKeyString(key)
	local keyLen = string.len(tostring(key))
	if keyLen < SERVER_KEY_LENGTH then
		for _ = 1, SERVER_KEY_LENGTH - keyLen do
			key = "0" .. key
		end
	end
	return tostring(key)
end

-- Adds a server to the list of servers saved in the Memory Store
function ServerList:appendServer(map)
	local serverNum = SortedMaps.getUniqueKey(map)
	local serverKey = self.createServerKeyString(serverNum)
	if serverKey and tonumber(serverKey) <= 999999 then
		local keyCheck = true
		local success, result = pcall(function()
			map:UpdateAsync(serverKey, function(keyExists)
				if keyExists then return nil end
				keyCheck = false
				TestService:Message("This is server number " .. tonumber(serverKey))
				return game.JobId
			end, SERVER_KEY_LIFETIME)
		end)
		if not success or keyCheck then
			task.wait(1)
			self:appendServer(map)
		else
			self.serverKey = serverKey
		end
	end
end

-- Removes a server from the list of servers saved in the Memory Store
function ServerList:removeServer(map)
	if self.serverKey and map then
		local success = pcall(function()
			map:RemoveAsync(self.serverKey)
		end)
		if not success then
			task.wait(5)
			self:removeServer(map)
		end
	end
end

function ServerList:init()
	task.spawn(function()
		-- If we want to save a list of servers, append this server to the list of servers and connect the server closed function
		if SAVE_SERVER_LIST then
			local serverListMap = SortedMaps.getSortedMap("ServerList")
			self:appendServer(serverListMap)
			game:BindToClose(function()
				self:removeServer(serverListMap)
			end)
		else
			local serverListMap = SortedMaps.getSortedMap("ServerList")
			task.spawn(function()
				SortedMaps.flush(serverListMap)
			end)
		end
	end)
end

return ServerList