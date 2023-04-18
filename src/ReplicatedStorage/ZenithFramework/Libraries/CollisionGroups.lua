-- Handles collision groups
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return {} end

local CollisionGroups = {}

local DEFAULT_GROUPS = {
	Player = {
		Player = false
	}
}

-- Creates a new collision group
function CollisionGroups.newCollisionGroup(groupName)
	assert(typeof(groupName) == "string", "Group name needs to be a string")

	if not CollisionGroups.groupExists(groupName) then
		PhysicsService:RegisterCollisionGroup(groupName)
	end
end

-- Checks if the collision group with the given name exists
function CollisionGroups.groupExists(groupName)
	assert(typeof(groupName) == "string", "Group name needs to be a string")

	for _, group in pairs(PhysicsService:GetRegisteredCollisionGroups()) do
		if group and group.name == groupName then
			return true
		end
	end
end

-- Assigns a collision group to an instance or model (if model, assigns to any added children too)
-- Creates the collision group if it doesn't exist
function CollisionGroups.assignGroup(obj, groupName)
	assert(obj:IsA("BasePart") or obj:IsA("Model"), "Object argument needs to be a BasePart or a Model")
	assert(typeof(groupName) == "string", "Group name needs to be a string")

	if not CollisionGroups.groupExists(groupName) then
		CollisionGroups.newCollisionGroup(groupName)
	end

	if obj:IsA("BasePart") then
		obj.CollisionGroup = groupName
	elseif obj:IsA("Model") then
		for _, part in pairs(obj:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CollisionGroup = groupName
			end
		end

		obj.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				part.CollisionGroup = groupName
			end
		end)
	end
end

-- Sets whether 2 collision groups should be collidable or not
function CollisionGroups.setGroupsCollidable(group1, group2, bool)
	assert(typeof(group1) == "string" and typeof(group2) == "string", "Group arguments need to be strings")
	assert(typeof(bool) == "boolean", "Bool argument needs to be a boolean")

	if CollisionGroups.groupExists(group1) and CollisionGroups.groupExists(group2) then
		PhysicsService:CollisionGroupSetCollidable(group1, group2, bool)
	end
end

-- Sets up the default collision groups
function CollisionGroups.setupDefaultGroups()
	for groupName, groupInfo in pairs(DEFAULT_GROUPS) do
		CollisionGroups.newCollisionGroup(groupName)

		for collidableGroupName, bool in pairs(groupInfo) do
			if CollisionGroups.groupExists(collidableGroupName) then
				CollisionGroups.setGroupsCollidable(groupName, collidableGroupName, bool)
			end
		end
	end
end

task.spawn(CollisionGroups.setupDefaultGroups)

return CollisionGroups