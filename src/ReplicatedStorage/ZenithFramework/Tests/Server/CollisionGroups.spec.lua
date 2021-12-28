local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local CollisionGroups = loadModule("CollisionGroups")

	local testName = "TestCollisionGroup"
	local testName2 = "TestCollisionGroup2"

    describe("CollisionGroups", function()
		it("should create a new collision group", function()
			expect(function()
				CollisionGroups.newCollisionGroup(testName)
			end).never.to.throw()
			expect(function()
				CollisionGroups.newCollisionGroup(5)
			end).to.throw()
		end)

		it("should check if a collision group exists or not", function()
			local exists
			expect(function()
				exists = CollisionGroups.groupExists(testName)
			end).never.to.throw()
			expect(exists).to.equal(true)
			expect(CollisionGroups.groupExists("DoesntExist")).never.to.be.ok()
			expect(function()
				CollisionGroups.groupExists(5)
			end).to.throw()
		end)

		it("should assign a collision group to a part or model", function()
			local newPart = Instance.new("Part", workspace)
			local newModel = Instance.new("Model", workspace)
			local newPart1 = Instance.new("Part", newModel)

			expect(function()
				CollisionGroups.assignGroup(newPart, testName)
			end).never.to.throw()
			expect(PhysicsService:GetCollisionGroupName(newPart.CollisionGroupId)).to.equal(testName)
			expect(function()
				CollisionGroups.assignGroup(newModel, testName)
			end).never.to.throw()
			for _, part in pairs(newModel:GetDescendants()) do
				expect(PhysicsService:GetCollisionGroupName(part.CollisionGroupId)).to.equal(testName)
			end
			expect(function()
				CollisionGroups.assignGroup(5, testName)
			end).to.throw()
			expect(function()
				CollisionGroups.assignGroup("Fail", testName)
			end).to.throw()

			newPart:Destroy()
			newModel:Destroy()
		end)

		it("should set whether two collision groups should be collidable or not", function()
			CollisionGroups.newCollisionGroup(testName2)
			expect(function()
				CollisionGroups.setGroupsCollidable(testName, testName2, false)
			end).never.to.throw()
			expect(PhysicsService:CollisionGroupsAreCollidable(testName, testName2)).to.equal(false)
			expect(function()
				CollisionGroups.setGroupsCollidable(5, testName2, false)
			end).to.throw()
			expect(function()
				CollisionGroups.setGroupsCollidable(testName, 5, false)
			end).to.throw()
		end)

		it("should set up the default collision groups", function()
			expect(function()
				CollisionGroups.setupDefaultGroups()
			end).never.to.throw()
		end)
	end)
end