local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CurrencyManager = loadModule("CurrencyManager")
local Llama = loadModule("Llama")
local MachineUtility = loadModule("MachineUtility")
local RoduxStore = loadModule("RoduxStore")

local upgradeMachineLevel = getDataStream("UpgradeMachineLevel", "RemoteFunction")
local setBuildOption = getDataStream("SetBuildOption", "RemoteFunction")

local assets = ReplicatedStorage.Assets

local Machine = {}
Machine.__index = Machine

function Machine.new(player : Player, data : table) : table
	local machineObj = assets.Machines[data.machineType .. "Machine"]:Clone()

	local self = setmetatable(Llama.Dictionary.join(data, {
		player = player;
		machine = machineObj;
	}), Machine)

	self:placeMachine()
end

function Machine:destroy() : nil

end

function Machine:placeMachine() : nil
	print(self.orientation)
	print(self.pos)
	self.machine:SetPrimaryPartCFrame(CFrame.new(self.pos)) --CFrame.fromOrientation(self.orientation) * CFrame.new(self.pos)

	self.machine.Parent = MachineUtility.getPlayerFolder(self.player)
end

function Machine:moveMachine() : nil
	-- TODO: Update self.orientation and self.pos

	self:placeMachine()
end

function Machine:upgradeLevel(levelType : string) : boolean
	local upgradeValues = RoduxStore:waitForValue("gameValues", "machines", self.machineType, levelType .. "Upgrades")
	local currentLevel = self[levelType .. "Level"]

	local upgradeDetails = upgradeValues[currentLevel + 1]

	if not upgradeDetails then
		warn(levelType .. " is already at max level for machine of type" .. self.machineType)
		return false
	end

	local success = CurrencyManager:transact(self.player, upgradeDetails.currency, upgradeDetails.cost)

	if success then
		self[levelType .. "Level"] = currentLevel + 1
	end

	return success
end

function Machine:setBuildOption(option : string) : boolean
	-- TODO: Checks to see if the option is valid and unlocked
end

function Machine:updatePropertiesByName(partPropertiesMap : table) : nil
	MachineUtility.updatePropertiesByName(self.machine, partPropertiesMap)
end

function Machine:upgradeControlPanel() : nil
	MachineUtility.upgradeControlPanel(self.machine)
end

function Machine.getPlayerMachine(player : Player, guid : string) : boolean
	-- TODO: Check RoduxStore for machine data
end

task.spawn(function()
	-- Allows for inheritance
	for _, module in script:GetChildren() do
		setmetatable(require(module), Machine)
	end

	while #Players:GetPlayers() == 0 do
		task.wait()
	end

	local part = workspace:FindFirstChild("Part")

	Machine.new(Players:GetPlayers()[1], {
		machineType = "Phone";
		pos = part.Position;
		orientation = part.Orientation;
	})
end)

return Machine


--[[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CurrencyManager = loadModule("CurrencyManager")
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
		local machineObj = assets.Machines[data.machineType .. "Machine"]:Clone()

		local self = setmetatable(Llama.Dictionary.join(data, {
			owner = player;
			machine = machineObj;
		}), MachineSystem)

		self:placeMachine()

		return self
	end

	-- TODO: Reset Machine on placement
	function MachineSystem:placeMachine() : nil
		self.machine.CFrame = CFrame.new(self.pos) * CFrame.fromOrientation(self.orientation)
		self.machine.Parent = getMachineFolder(self.owner)
	end

	function MachineSystem:moveMachine(newPos : Vector3, newOrientation : Vector3)
		self.pos = newPos
		self.orientation = newOrientation

		self:placeMachine()
	end

	function MachineSystem:upgradeLevel(upgradeType : string) : boolean
		upgradeType = upgradeType .. "Level"

		if not self[upgradeType] then
			warn("Invalid machine upgrade type")
			return false
		end

		local currentLevel = self[upgradeType]

		local machineValues = RoduxStore:waitForValue("gameValues", "machines", string.lower(self.machineType))
		local upgradeDetails = machineValues.speedUpgrades[currentLevel + 1]

		if upgradeDetails then
			local success = CurrencyManager:transact(self.owner, upgradeDetails.currency, - upgradeDetails.cost)

			if success then
				self[upgradeType] = currentLevel + 1
				-- TODO: Update Physical Machine

				return true
			else
				-- TODO: Fire Currency Shop
				return false
			end
		end

		return false
	end

	function MachineSystem:destroy()

	end
else

end

--[[
task.spawn(function()
	for _, module in script:GetChildren() do
		setmetatable(require(module), MachineSystem)
	end
end)



return MachineSystem
]]