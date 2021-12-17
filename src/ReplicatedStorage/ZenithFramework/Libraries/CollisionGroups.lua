-- Handles collision groups
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local CollisionGroups = {}

local DEFAULT_GROUPS = {
    Player = {
        Player = false
    }
}

if RunService:IsServer() then
    -- Creates a new collision group
    function CollisionGroups.newCollisionGroup(groupName)
        if not CollisionGroups.groupExists(groupName) then
            PhysicsService:CreateCollisionGroup(groupName)
        end
    end

    -- Checks if the collision group with the given name exists
    function CollisionGroups.groupExists(groupName)
        for _, group in pairs(PhysicsService:GetCollisionGroups()) do
            if group and group.name == groupName then
                return true
            end
        end
    end

    -- Assigns a collision group to an instance or model (if model, assigns to any added children too)
    -- Creates the collision group if it doesn't exist
    function CollisionGroups.assignGroup(obj, groupName)
        if not CollisionGroups.groupExists(groupName) then
            CollisionGroups.newCollisionGroup(groupName)
        end
        
        if obj:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(obj, groupName)
        elseif obj:IsA("Model") then
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    PhysicsService:SetPartCollisionGroup(part, groupName)
                end
            end

            obj.DescendantAdded:Connect(function(part)
                if part:IsA("BasePart") then
                    PhysicsService:SetPartCollisionGroup(part, groupName)
                end 
            end)
        end
    end

    -- Sets whether 2 collision groups should be collidable or not
    function CollisionGroups.setGroupsCollidable(group1, group2, bool)
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
end

return CollisionGroups