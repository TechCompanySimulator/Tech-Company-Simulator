local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local MachineUtility = loadModule("MachineUtility")

local SPEED_UPGRADE_PROPERTIES = {
	[3] = {
		Pipe = MachineUtility.METAL_PROPERTIES;
	};
	[4] = {
		Main = MachineUtility.METAL_PROPERTIES;
		LeftDoor = MachineUtility.METAL_PROPERTIES;
		RightDoor = MachineUtility.METAL_PROPERTIES;
	};
	[5] = {
		Pipe = MachineUtility.CHROME_PROPERTIES;
		Main = MachineUtility.CHROME_PROPERTIES;
		Input = MachineUtility.CHROME_PROPERTIES;
		Ring = MachineUtility.CHROME_DETAILING_PROPERTIES;
	};
}

local PhoneMachine = {}

function PhoneMachine:setSpeedProperties()
	local speedLevel = self.speedLevel

	if speedLevel == 2 then
		self:upgradeControlPanel()
	else
		self:updatePropertiesByName(SPEED_UPGRADE_PROPERTIES[speedLevel])
	end
end

return PhoneMachine