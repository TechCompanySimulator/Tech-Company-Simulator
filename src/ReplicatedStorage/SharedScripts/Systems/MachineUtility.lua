local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local VALID_LEVEL_TYPES = {
	"speed";
	"quality";
}

local MachineUtility = {}

function MachineUtility.isValidLevelType(levelType: string): boolean
	return table.find(VALID_LEVEL_TYPES, levelType) ~= nil
end

function MachineUtility.getMachineValues(machineType: string): table?
	local machineValues = RoduxStore:waitForValue("gameValues", "machines")[machineType:lower()]

	if not machineValues then
		warn("Machine values not found for machine type: " .. machineType)
		return
	end

	return machineValues
end

function MachineUtility.getBuildItems(machineType: string): table?
	local machineValues = MachineUtility.getMachineValues(machineType)

	return if machineValues then machineValues.buildItems else nil
end

function MachineUtility.getUpgradeValues(machineType: string, levelType: string): table?
	if not MachineUtility.isValidLevelType(levelType) then return end

	local machineValues = MachineUtility.getMachineValues(machineType)

	return if machineValues then machineValues[levelType .. "Upgrades"] else nil
end

-- TODO: Function to upgrade machine looks to match levels, with machineModel as argument

return MachineUtility