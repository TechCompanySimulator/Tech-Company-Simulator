local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local RoduxStore = loadModule("RoduxStore")

local assets = ReplicatedStorage.Assets

local MachineSystem = {}
MachineSystem.__index = MachineSystem

if RunService:IsServer() then
	local function getMachineFolder(player : Player) : Instance
		-- TODO: Get Player Machine Folder

		return workspace
	end

	-- Required args = machineType, speedLevel, qualityLevel, pos, orientation
	function MachineSystem.new(player : Player, data : table) : table
		local machineObj = assets.Machines[data.machineType]:Clone()

		local self = setmetatable(Llama.Dictionary.join(data, {
			owner = player;
			machine = machineObj;
		}), MachineSystem)

		self:placeMachine()

		return self
	end

	-- TODO: Reset Machine on placement
	function MachineSystem:placeMachine()
		self.machine.CFrame = CFrame.new(self.pos) * CFrame.fromOrientation(self.orientation)
		self.machine.Parent = getMachineFolder(self.owner)
	end

	function MachineSystem:moveMachine(newPos, newOrientation)
		self.pos = newPos
		self.orientation = newOrientation

		self:placeMachine()
	end

	function MachineSystem:upgradeSpeed()
		local currentSpeedLevel = self.speedLevel
		
		local machineValues = RoduxStore:waitForValue("gameValues", "machines", string.lower(self.machineType))
		local upgradeDetails = machineValues.speedUpgrades[currentSpeedLevel + 1]

		if upgradeDetails then
			
		end

		return false
	end

	function MachineSystem:upgradeQuality()
		
	end

	function MachineSystem:destroy()
		
	end
else

end


return MachineSystem