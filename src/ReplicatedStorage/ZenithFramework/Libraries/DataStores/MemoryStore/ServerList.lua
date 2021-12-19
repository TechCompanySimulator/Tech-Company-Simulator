local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestService = game:GetService("TestService")
local MessagingService = game:GetService("MessagingService")

if RunService:IsClient() then return {} end

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local SortedMaps = loadModule("SortedMaps")

local ServerList = {
	_hostBinds = {}
}

local SAVE_SERVER_LIST = true
local CHOOSE_HOST_SERVER = true
local SERVER_KEY_LENGTH = 6
local SERVER_KEY_LIFETIME = 2592000
local SERVER_LIST_TOPIC = "ServerListEvent"

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
			ServerList:setAsHost()
		end
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
			print("Appending again")
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

-- Binds a function to run if the server is set as the host
function ServerList:bindHostFunction(callback)
	if callback and typeof(callback) == "function" then
		table.insert(self._hostBinds, callback)
	end
end

-- Runs all bound host functions if/when this server is set as the host
function ServerList:setAsHost()
	ServerList.isHostServer = true
	for _, callback in pairs(self._hostBinds) do
		if callback and typeof(callback) == "function" then
			task.spawn(callback)
		end
	end
	TestService:Message("This server is now the host")
end

function ServerList:initiate()
	task.spawn(function()
		-- If we want to save a list of servers, append this server to the list of servers and connect the server closed function
		if SAVE_SERVER_LIST then
			local serverListMap = SortedMaps.getSortedMap("ServerList")
			ServerList.appendServer(serverListMap)

			-- Subscribe to the server list topic, and when the host shuts down, check if this server is next in line to be the host
			local subscribeSuccess, subscribeConnection = pcall(function()
				return MessagingService:SubscribeAsync(SERVER_LIST_TOPIC, function(message)
					if message and message.Data and ServerList.serverKey and message.Data == "HostShutdown" then
						local serverList = SortedMaps.getSortedMap("ServerList"):GetRangeAsync(Enum.SortDirection.Ascending, 100)
						if self.serverKey == serverList[1].key then
							self:setAsHost()
						end
					end
				end)
			end)

			game:BindToClose(function()
				ServerList.removeServer(serverListMap)
				if subscribeSuccess then
					subscribeConnection:Disconnect()
				end
				-- If this is the host server, publish a message to all servers that the host has shut down
				if CHOOSE_HOST_SERVER and ServerList.isHostServer then
					local publishSuccess, publishResult = pcall(function()
						MessagingService:PublishAsync(SERVER_LIST_TOPIC, "HostShutdown")
					end)
					if not publishSuccess then
						print(publishResult)
					end
				end
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