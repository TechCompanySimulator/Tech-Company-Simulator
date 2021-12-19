local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if RunService:IsClient() then return {} end

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local SortedMaps = loadModule("SortedMaps")

local ServerList = {}

local SAVE_SERVER_LIST = true
local CHOOSE_HOST_SERVER = true
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
function ServerList.appendServer(map)
	local serverNum, isFirstKey = SortedMaps.getUniqueKey(map)
	local serverKey = ServerList.createServerKeyString(serverNum)
	if serverKey and tonumber(serverKey) <= 999999 then
		ServerList.serverKey = serverKey
		if isFirstKey and CHOOSE_HOST_SERVER then
			ServerList.isHostServer = true
			print("This server is the host")
		end
		local keyExists = true
		local success = pcall(function()
			map:UpdateAsync(serverKey, function(keyExists)
				if keyExists then return nil end
				keyExists = false
				print("This is server number " .. tonumber(serverKey))
				return game.JobId
			end, SERVER_KEY_LIFETIME)
		end)
		if not success or keyExists then
			task.wait(1)
			ServerList.appendServer()
		end
	end
end

-- Removes a server from the list of servers saved in the Memory Store
function ServerList.removeServer(map)
	if ServerList.serverKey and map then
		local success = pcall(function()
			map:RemoveAsync(ServerList.serverKey)
		end)
		if not success then
			task.wait(5)
			ServerList.removeServer(map)
		end
	end
end

-- If we want to save a list of server, append this server to the list of servers and connect the server closed function
if SAVE_SERVER_LIST then
	local serverListMap = SortedMaps.getSortedMap("ServerList")
	task.spawn(function()
		ServerList.appendServer(serverListMap)
	end)

	game:BindToClose(function()
		ServerList.removeServer(serverListMap)
		if CHOOSE_HOST_SERVER and ServerList.isHostServer then
			print("Need to choose new host server!")
		end
	end)
else
	local serverListMap = SortedMaps.getSortedMap("ServerList")
	task.spawn(function()
		SortedMaps.flush(serverListMap)
	end)
end

return ServerList