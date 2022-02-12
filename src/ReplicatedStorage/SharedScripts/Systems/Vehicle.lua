local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Vehicle = {}
Vehicle.__index = Vehicle

-- Creates a new vehicle object
function Vehicle.new(contents)
	local self = setmetatable({}, Vehicle)

	local baseSpeed = contents.speed or 20
	self.speed = baseSpeed
	self.baseSpeed = baseSpeed
	self.turnSpeed = contents.turnSpeed or 5
	self.turnAngle = contents.turnAngle or 25
	self.reverseSpeed = contents.reverseSpeed or 10

	return self
end

-- Boosts the vehicle for a duration, or permanently if there is no duration
function Vehicle:boost(scale, duration)
	self.speed = self.baseSpeed * scale
	if duration then
		task.wait(duration)
		self.speed = self.baseSpeed
	end
end

-- Sets the base speed of the vehicle
function Vehicle:setBaseSpeed(speed)
	self.baseSpeed = speed
	self.speed = speed
end

return Vehicle