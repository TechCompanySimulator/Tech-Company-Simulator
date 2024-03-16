local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CurrencyManager = loadModule("CurrencyManager")
local Llama = loadModule("Llama")
local PlayerDataManager = loadModule("PlayerDataManager")
local ResearchSystem = loadModule("ResearchSystem")
local RoduxStore = loadModule("RoduxStore")

local addServerMachine = loadModule("addServerMachine")
local updateServerMachine = loadModule("updateServerMachine")
local removeServerMachine = loadModule("removeServerMachine")
local startServerMachineSession = loadModule("startServerMachineSession")
local endServerMachineSession = loadModule("endServerMachineSession")

local upgradeMachine = getDataStream("UpgradeMachine", "RemoteFunction")
local setBuildOption = getDataStream("SetMachineBuildOption", "RemoteFunction")

local assets = ReplicatedStorage.Assets

local Machine = {
	playerMachines = {};
}
Machine.__index = Machine


-- TODO: Save to player Data
function Machine.initiate(): nil
	-- Allows for inheritance
	for _, module in script:GetChildren() do
		setmetatable(require(module), Machine)
	end

	PlayerDataManager:playerAdded(Machine.playerAdded)
	Players.PlayerRemoving:Connect(Machine.playerRemoving)
end

function Machine.start()
	-- TODO: Debounces
	upgradeMachine.OnServerInvoke = function(player: Player, guid: string, levelType: string): boolean
		local machine = Machine.getPlayerMachine(player, guid)

		if machine then
			return machine:upgradeLevel(levelType)
		end

		return false
	end

	setBuildOption.OnServerInvoke = function(player: Player, guid: string, option: string): boolean
		local machine = Machine.getPlayerMachine(player, guid)

		if machine then
			return machine:setBuildOption(option)
		end

		return false
	end
end

function Machine.getPlayerMachine(player: Player, guid: string): table?
	local playerMachines = Machine.playerMachines[tostring(player.UserId)]

	if playerMachines then
		return playerMachines[guid]
	end
end

-- Create the player's machines from the player's data and add them to the Rodux store
function Machine.playerAdded(player: Player, playerData: table): nil
	local machineInvData = playerData.Inventory.Machines or {}

	local machines = {}

	for _, machineData in machineInvData do
		machines[machineData.guid] = Machine.new(player, machineData, true)
	end

	-- Create a copy of the machines to avoid modifying the Rodux store when modifying the machines
	local roduxMachineData = Llama.Dictionary.map(machines, function(machine)
		return table.clone(machine)
	end)

	Machine.playerMachines[tostring(player.UserId)] = machines
	RoduxStore:dispatch(startServerMachineSession(player.UserId, roduxMachineData))

	-- TODO: Remove Testing Code Below
	while #Players:GetPlayers() == 0 do task.wait() end

	local part = workspace:FindFirstChild("MachineTestPart")

	Machine.new(Players:GetPlayers()[1], {
		machineType = "Phone";
		position = part.Position;
		orientation = part.Orientation;
	})
end

function Machine.playerRemoving(player: Player): nil
	-- Remove all the player's machines from the Rodux store
	RoduxStore:dispatch(endServerMachineSession(player.UserId))

	local playerMachines = Machine.playerMachines[tostring(player.UserId)] or {}

	for _, machine in playerMachines do
		machine:destroy(true)
	end

	Machine.playerMachines[tostring(player.UserId)] = nil
end

function Machine.new(player: Player, data: table?, onPlayerAdded: boolean?): table
	local machineModel = assets.Machines[data.machineType .. "Machine"]:Clone()

	-- TODO: Don't get guid if onPlayerAdded
	local self = setmetatable(Llama.Dictionary.join({
		player = player;
		machine = machineModel;
		guid = HttpService:GenerateGUID(false);
		speedLevel = 1;
		qualityLevel = 1;
	}, data), Machine)

	self:placeMachine()

	-- This is handled seperately for initiating the player's machines to reduce the amount of dispatches
	if not onPlayerAdded then
		Machine.playerMachines[tostring(player.UserId)][self.guid] = self
		RoduxStore:dispatch(addServerMachine(player.UserId, table.clone(self)))
	end

	return self
end

function Machine:writeToRodux(newData: table): nil
	RoduxStore:dispatch(updateServerMachine(self.player.UserId, self.guid, newData))
end

-- TODO: Integrate with the PlotSystem
function Machine:placeMachine(): nil
	self.machine:SetPrimaryPartCFrame(CFrame.new(self.position))

	self.machine.Parent = workspace
end

function Machine:setBuildOption(option: number): boolean
	if typeof(option) ~= "number" then return false end

	if ResearchSystem.hasPlayerResearched(self.player, self.machineType, option) then
		self.buildOption = option

		self:writeToRodux({
			buildOption = option;
		})

		return true
	end

	return false
end

-- TODO: Update Physical Properties of Machine
function Machine:upgradeLevel(levelType: string): boolean
	if not (levelType == "speed" or levelType == "quality") then return false end

	local upgradeValues = RoduxStore:waitForValue("gameValues", "machines", self.machineType:lower(), levelType:lower() .. "Upgrades")

	-- Upgrade costs are indexed from 1 onwards, with 1 representing costs for level 2 etc
	local currentLevel = self[levelType .. "Level"]
	local upgradeDetails = upgradeValues[currentLevel]

	if not upgradeDetails then
		warn(levelType .. " is already at max level for machine of type " .. self.machineType)
		return false
	end

	if CurrencyManager:transact(self.player, upgradeDetails.currency, -upgradeDetails.cost) then
		self[levelType .. "Level"] = currentLevel + 1

		self:writeToRodux({
			[levelType .. "Level"] = currentLevel + 1;
		})

		return true
	end

	return false
end

function Machine:destroy(isPlayerLeaving: boolean?): nil
	-- Only remove from the Rodux store if the player is not leaving to avoid multiple dispatches
	if not isPlayerLeaving then
		RoduxStore:dispatch(removeServerMachine(self.player.UserId, self.guid))
	end

	self.machine:Destroy()
end

return Machine