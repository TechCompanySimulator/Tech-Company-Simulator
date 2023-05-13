local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
    local CameraLib = loadModule("Camera")
	local Camera = workspace.CurrentCamera

    describe("CameraLibrary", function()
        it("should fix the camera at it's current position", function()
			expect(function()
				CameraLib:setCameraType("FixedPoint")
			end).never.to.throw()
			expect(Camera.CameraType).to.equal(Enum.CameraType.Scriptable)
        end)

		it("should return the camera to the player", function()
			expect(function()
				CameraLib:returnToPlayer()
			end).never.to.throw()
			expect(Camera.CameraType).to.equal(Enum.CameraType.Custom)
        end)
    end)

	afterAll(function()
		CameraLib:returnToPlayer()
	end)
end