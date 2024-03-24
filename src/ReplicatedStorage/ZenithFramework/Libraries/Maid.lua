-- Handles the storing and cleaning up of connections
-- Author: TheM0rt0nator

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
function Maid:GiveTask(_task)
	table.insert(self.connections, _task)
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
end

Maid.giveTask = Maid.GiveTask
Maid.doCleaning = Maid.DoCleaning

return Maid