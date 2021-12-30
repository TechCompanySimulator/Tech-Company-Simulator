local TestService = game:GetService("TestService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return {} end

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local BindedHostFunctionEvent = getDataStream("BindedHostFunctionEvent", "BindableEvent")

local SortedMaps = loadModule("SortedMaps")

local HostServer = {
	_binds = {};
	hasFunctionality = false;
	isHost = false;
}

local CHOOSE_HOST_SERVER = true
local HOST_SERVER_MAP = "HostServer"
local HOST_SERVER_TOPIC = "HostServerTopic"
local SERVER_KEY_LIFETIME = 2592000

-- Function runs when this module is loaded
function HostServer:initiate()
	if CHOOSE_HOST_SERVER then
		task.spawn(function()
			self:attemptHostSet()
		end)
		
		-- Subscribe to the server list topic, and when the host shuts down, check if this server is next in line to be the host
		MessagingService:SubscribeAsync(HOST_SERVER_TOPIC, function(message)
			if message and message.Data and self.serverKey then 
				if message.Data == "HostShutdown" then
					self:attemptHostSet()
				end
			end
		end)

		game:BindToClose(function()
			-- If this is the host server, publish a message to all servers that the host has shut down
			if not RunService:IsStudio() and self.isHost then
				local hostServerMap = SortedMaps.getSortedMap(HOST_SERVER_MAP)
				-- Remove the host server from the memory store
				local function removeHost()
					local success = pcall(function()
						return hostServerMap:RemoveAsync("HostServer")
					end)
					if not success then
						task.wait(1)
						removeHost()
					end
				end

				local publishSuccess, publishResult = pcall(function()
					MessagingService:PublishAsync(HOST_SERVER_TOPIC, "HostShutdown")
				end)
				if not publishSuccess then
					print(publishResult)
				end
			end
		end)
	end
end

-- Binds a function to run if the server is set as the host
function HostServer:bindHostFunction(callback)
	if callback and typeof(callback) == "function" then
		table.insert(self._binds, {
			callback = callback;
		})
		self.hasFunctionality = true
		BindedHostFunctionEvent:Fire()
	end
end

-- Attempts to set this server as the host server and runs all bound host functions if/when this server is set as the host
function HostServer:attemptHostSet()
	local hostServerMap = SortedMaps.getSortedMap(HOST_SERVER_MAP)
	local setSuccessfully = SortedMaps.createNewKey(hostServerMap, "HostServer", ((not RunService:IsStudio() and game.JobId) or "Worked!"), SERVER_KEY_LIFETIME)
	if setSuccessfully then
		self.isHost = true
		if not self.hasFunctionality then
			BindedHostFunctionEvent.Event:Wait()
		end
		for _, bind in pairs(self._binds) do
			if bind.callback and typeof(bind.callback) == "function" then
				task.spawn(bind.callback)
			end
		end
		TestService:Message("This server is now the host")
	end
end

-- Runs a while loop to repeatedly check if there is a host server and set a new host if there isn't 
function HostServer:hostCheck()
	self.hostCheckRunning = true
	task.spawn(function()
		while self.hostCheckRunning do
			task.wait(30)
			self:attemptHostSet()
		end
	end)
end

return HostServer