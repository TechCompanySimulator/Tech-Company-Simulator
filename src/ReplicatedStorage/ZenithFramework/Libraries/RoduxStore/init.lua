-- Sets up the rodux store on the server and the client

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxReplicationEvent = getDataStream("RoduxReplicationEvent", "RemoteEvent")
local RoduxReplicationFunc = getDataStream("RoduxReplicationFunction", "RemoteFunction")

local Rodux = loadModule("Rodux")
local Reducer = loadModule("Reducer")
local ReplicationMiddleware = loadModule("ReplicationMiddleware")

local RoduxStore = {}

if RunService:IsClient() then
	local initialState = RoduxReplicationFunc:InvokeServer()

	RoduxStore = Rodux.Store.new(Reducer, initialState)

	RoduxReplicationEvent.OnClientEvent:Connect(function(action)
		RoduxStore:dispatch(action)
	end)
elseif RunService:IsServer() then

	RoduxStore = Rodux.Store.new(Reducer, {}, {ReplicationMiddleware})

	RoduxReplicationFunc.OnServerInvoke = function()
		return RoduxStore:getState()
	end
end

return RoduxStore