local HttpService = game:GetService("HttpService")
-- Handles the storing and cleaning up of connections

local Maid = {}
Maid.__index = Maid

local function disconnectTask(cleanupTask)
	if typeof(cleanupTask) == "RBXScriptConnection" then
		cleanupTask:Disconnect()
	elseif typeof(cleanupTask) == "function" then
		cleanupTask()
	elseif typeof(cleanupTask) == "thread" then
		task.cancel(cleanupTask)
	elseif typeof(cleanupTask) == "Instance" then
		cleanupTask:Destroy()
	elseif typeof(cleanupTask) == "table" and typeof(cleanupTask.destroy) == "function" then
		cleanupTask:destroy()
	end
end

-- Creates a new maid object
function Maid.new()
	local self = setmetatable({}, Maid)

	self.connections = {}

	return self
end

-- Stores a task in the maid
function Maid:GiveTask(cleanupTask, index)
	index = index or HttpService:GenerateGUID(false)
	self.connections[index] = cleanupTask
end

-- Clears all tasks stored in the maid
function Maid:DoCleaning()
	for index, cleanupTask in self.connections do
		if typeof(cleanupTask) ~= "RBXScriptConnection" then continue end

		self.connections[index] = nil
		disconnectTask(cleanupTask)
	end

	local key, cleanupTask = next(self.connections)

	while cleanupTask ~= nil do
		self.connections[key] = nil
		disconnectTask(cleanupTask)

		key, cleanupTask = next(cleanupTask)
	end

	self.connections = {}
end

function Maid:Remove(index)
	if not self.connections[index] then warn("No task with index ", index, " found in maid") return end

	self.connections[index]:Disconnect()
	self.connections[index] = nil
end

Maid.giveTask = Maid.GiveTask
Maid.doCleaning = Maid.DoCleaning
Maid.remove = Maid.Remove

return Maid