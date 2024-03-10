local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local MachineUtility = {}

-- TODO: Function to upgrade machine looks to match levels, with machineModel as argument

function MachineUtility.getMachineValues(machineType: string)
	return RoduxStore:waitForValue("gameValues", "machines")[machineType:lower()]
end

function MachineUtility.getBuildItems(machineType: string)
	local machineValues = MachineUtility.getMachineValues(machineType)

	if not machineValues then
		warn("Machine values not found for machine type: " .. machineType)
		return
	end

	return machineValues.buildItems
end

return MachineUtility