local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return {} end

local _, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxReplicationEvent = getDataStream("RoduxReplicationEvent", "RemoteEvent")

local ReplicationMiddleware
ReplicationMiddleware = function(nextDispatch, store)
	return function(action)
		if not action.replicationTargets or action.replicationTargets == "all" then
			RoduxReplicationEvent:FireAllClients(action)
		else
			for _, player in pairs(action.replicationTargets) do
				RoduxReplicationEvent:FireClient(player, action)
			end
		end
		nextDispatch(action)
	end
end

return ReplicationMiddleware