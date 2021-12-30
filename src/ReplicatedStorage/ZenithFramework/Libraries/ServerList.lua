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
	assert(typeof(key) == "number", "Key argument must be a number")

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
		local setSuccessfully = SortedMaps.createNewKey(map, serverKey, ((not RunService:IsStudio() and game.JobId) or "Worked!"), SERVER_KEY_LIFETIME)
		if not setSuccessfully then
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
			return map:RemoveAsync(self.serverKey)
		end)
		if not success then
			task.wait(5)
			self:removeServer(map)
		end
	end
end

function ServerList:initiate()
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