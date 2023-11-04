local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local ResearchSystem = loadModule("ResearchSystem")
local RoduxStore = loadModule("RoduxStore")

local MachineUtility = {
	METAL_PROPERTIES = {
		Material = Enum.Material.Metal;
		Color = Color3.fromRGB(163, 162, 165);
	};
	CHROME_PROPERTIES = {
		Material = Enum.Material.SmoothPlastic;
		Color = Color3.fromRGB(99, 95, 98);
		Reflectance = 0.4;
	};
	CHROME_DETAILING_PROPERTIES = {
		Color = Color3.fromRGB(255, 176, 0);
	};
}

function MachineUtility.getPlayerFolder(player : Player) : Instance
	-- TODO: Implement

	return workspace
end

function MachineUtility.getMachineDisplayName(machineType : string) : string
	local machineData = RoduxStore:waitForValue("gameValues", "machines", string.lower(machineType))

	return machineData.displayName
end

function MachineUtility.isItemResearched(player : Player, machineType : string, itemIndex : number) : boolean
	local playerMachineLevel = ResearchSystem.getPlayerLevel(player, machineType)

	return playerMachineLevel >= itemIndex
end

function MachineUtility.getUpgradeCost(machineType : string, levelType : string, level : number) : table
	levelType = string.lower(levelType)
	machineType = string.lower(machineType)

	local machineData = RoduxStore:waitForValue("gameValues", "machines", machineType, levelType .. "Upgrades")

	return machineData[level - 1]
end

function MachineUtility.isLevelValid(machineType : string, levelType : string, level : number) : boolean
	return MachineUtility.getUpgradeCost(machineType, levelType, level) ~= nil
end

-- Updates the physical properties of a model, based on their name and the properties passed in
function MachineUtility.updatePropertiesByName(model : Model, partPropertiesMap : table) : nil
	for _, obj in model:GetDescendants() do
		if not partPropertiesMap[obj.Name] or not obj:IsA("BasePart") then continue end

		for property, value in partPropertiesMap[obj.Name] do
			obj[property] = value
		end
	end
end

function MachineUtility.upgradeControlPanel(model : Model) : nil

end


return MachineUtility