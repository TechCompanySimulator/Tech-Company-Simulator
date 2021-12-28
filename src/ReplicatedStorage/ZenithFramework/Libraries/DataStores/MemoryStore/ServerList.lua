local TestService = game:GetService("TestService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
local HOST_CHECK_TIME = 600

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
	local serverNum, isFirstKey = SortedMaps.getUniqueKey(map)
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
			if isFirstKey and CHOOSE_HOST_SERVER then
				self:setAsHost()
			end
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

-- Binds a function to run if the server is set as the host
function ServerList:bindHostFunction(callback)
	if callback and typeof(callback) == "function" then
		local wasRun = false
		if self.hostKey == self.serverKey and self.hostFunctionsComplete then
			-- Need to run the function if the server was already set as the host
			wasRun = true
			task.spawn(callback)
		end
		table.insert(self._hostBinds, {
			wasRun = wasRun;
			callback = callback;
		})
	end
end

-- Runs all bound host functions if/when this server is set as the host
function ServerList:setAsHost()
	self.checkingHost = false
	self.hostKey = self.serverKey
	for _, bind in pairs(self._hostBinds) do
		if bind.callback and not bind.wasRun and typeof(bind.callback) == "function" then
			bind.wasRun = true
			task.spawn(bind.callback)
		end
	end
	self.hostFunctionsComplete = true
	TestService:Message("This server is now the host")
end

-- Loops through the server list to make sure this server is up to date with the host
-- If not up to date, sends a message to ensure all other server including the hose are up to date
-- This is just for extra protection, so every server is always checking and if for some reason a message fails it the host will hopefully be found after the next check
function ServerList:hostCheck()
	self.checkingHost = true
	task.spawn(function()
		while self.checkingHost do
			task.wait(HOST_CHECK_TIME)
			local serverList = SortedMaps.getSortedMap("ServerList"):GetRangeAsync(Enum.SortDirection.Ascending, 100)
			if serverList[1] and self.hostKey ~= serverList[1].key then
				self.hostKey = serverList[1].key
				local publishSuccess, publishResult = pcall(function()
					MessagingService:PublishAsync(SERVER_LIST_TOPIC, "HostCheck")
				end)
				if not publishSuccess then
					print(publishResult)
				end
			end
		end
	end)
end

function ServerList:init()
	task.spawn(function()
		-- If we want to save a list of servers, append this server to the list of servers and connect the server closed function
		if SAVE_SERVER_LIST then
			local serverListMap = SortedMaps.getSortedMap("ServerList")
			self:appendServer(serverListMap)

			-- Subscribe to the server list topic, and when the host shuts down, check if this server is next in line to be the host
			local subscribeSuccess, subscribeConnection = pcall(function()
				return MessagingService:SubscribeAsync(SERVER_LIST_TOPIC, function(message)
					if message and message.Data and self.serverKey then 
						if message.Data == "HostShutdown" then
							local serverList = SortedMaps.getSortedMap("ServerList"):GetRangeAsync(Enum.SortDirection.Ascending, 100)
							if serverList[1] and self.serverKey == serverList[1].key then
								self:setAsHost()
							end
						elseif message.Data == "HostCheck" then
							local serverList = SortedMaps.getSortedMap("ServerList"):GetRangeAsync(Enum.SortDirection.Ascending, 100)
							if serverList[1] then
								self.hostKey = serverList[1].key
								if self.serverKey == serverList[1].key then
									self:setAsHost()
								end
							end
						end
					end
				end)
			end)

			if self.hostKey ~= self.serverKey then
				self:hostCheck()
			end

			game:BindToClose(function()
				self:removeServer(serverListMap)
				if subscribeSuccess then
					subscribeConnection:Disconnect()
				end
				-- If this is the host server, publish a message to all servers that the host has shut down
				if CHOOSE_HOST_SERVER and self.hostKey == self.serverKey then
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