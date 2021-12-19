local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return {} end

local Queues = {}

-- Created a memory store queue with the given name, and saves it in this module
function Queues.createQueue(queueName)
	local newQueue = MemoryStoreService:GetQueue(queueName)
	Queues[queueName] = newQueue
end

return Queues