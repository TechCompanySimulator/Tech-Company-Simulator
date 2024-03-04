local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CurrencyManager = loadModule("CurrencyManager")
local Llama = loadModule("Llama")
local RoduxStore = loadModule("RoduxStore")

local addServerMachine = loadModule("addServerMachine")
local updateServerMachine = loadModule("updateServerMachine")
local removeServerMachine = loadModule("removeServerMachine")
local removeAllServerMachines = loadModule("removeAllServerMachines")

local upgradeMachine = getDataStream("UpgradeMachine", "RemoteEvent")
local setBuildOption = getDataStream("SetMachineBuildOption", "RemoteEvent")

local assets = ReplicatedStorage.Assets

local Machine = {
	playerMachines = {};
}
Machine.__index = Machine

function Machine.initiate(): nil
	-- Allows for inheritance
	for _, module in script:GetChildren() do
		setmetatable(require(module), Machine)
	end

	for _, player in Players:GetPlayers() do
		Machine.playerAdded(player)
	end

	Players.PlayerAdded:Connect(Machine.playerAdded)
	Players.PlayerRemoving:Connect(Machine.playerRemoving)

	-- TODO: Remove Testing Code Below
	while #Players:GetPlayers() == 0 do task.wait() end

	local part = workspace:FindFirstChild("MachineTestPart")

	Machine.new(Players:GetPlayers()[1], {
		machineType = "Phone";
		position = part.Position;
		orientation = part.Orientation;
	})
end

function Machine.new(player: Player, data: table?): table
	local machineModel = assets.Machines[data.machineType .. "machine"]:Clone()

	local self = setmetatable(Llama.Dictionary.join({
		player = player;
		machine = machineModel;
		guid = HttpService:GenerateGUID(false);
		speedLevel = 1;
		qualityLevel = 1;
	}, data), Machine)

	self:placeMachine()

	RoduxStore:dispatch(addServerMachine(player.UserId, self))

	return self
end

-- TODO: Only save certain info to Rodux?
function Machine:writeToRodux(newData: table): nil
	RoduxStore:dispatch(updateServerMachine(self.player.UserId, self.guid, newData))
end

-- TODO: Integrate with the PlotSystem
function Machine:placeMachine(): nil
	self.machine:SetPrimaryPartCFrame(CFrame.new(self.position))

	self.machine.Parent = workspace
end

function Machine:setBuildOption(option: string): boolean

end

function Machine:upgradeLevel(levelType: string): boolean

end

function Machine:destroy(isPlayerLeaving: boolean?): nil
	-- Only remove from the Rodux store if the player is not leaving to avoid multiple dispatches
	if not isPlayerLeaving then
		RoduxStore:dispatch(removeServerMachine(self.player.UserId, self.guid))
	end

	self.machine:Destroy()
end

function Machine.getPlayerMachine(player: Player, guid: string): table?
	local playerMachines = Machine.playerMachines[tostring(player.UserId)]

	if playerMachines then
		return playerMachines[guid]
	end
end

function Machine.playerAdded(player: Player): nil
	Machine.playerMachines[tostring(player.UserId)] = {}
end

function Machine.playerRemoving(player: Player): nil
	-- Remove all the player's machines from the Rodux store
	RoduxStore:dispatch(removeAllServerMachines(player.UserId))

	local playerMachines = Machine.playerMachines[tostring(player.UserId)] or {}

	for _, machine in playerMachines do
		machine:destroy(true)
	end

	Machine.playerMachines[tostring(player.UserId)] = nil
end

return Machine