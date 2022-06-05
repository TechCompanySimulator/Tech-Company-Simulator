local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local ProximityManager = loadModule("ProximityManager")
local ProximityPrompt = loadModule("ProximityPrompt")
local RoduxStore = loadModule("RoduxStore")
local Signal = loadModule("Signal")
local String = loadModule("String")
local Tween = loadModule("Tween")

local addMachine = loadModule("addMachine")
local editMachineValues = loadModule("editMachineValues")

local useMachine = getDataStream("UseMachine", "RemoteEvent")
local upgradeMachine = getDataStream("UpgradeMachine", "RemoteFunction")

local assets = ReplicatedStorage.Assets

local Machine = {}
Machine.__index = Machine
Machine.playerMachines = {}

local player
if RunService:IsClient() then
	player = Players.LocalPlayer
	Machine._signal = Signal.new()
end

function Machine.new(machine, owner)
	local self = setmetatable(machine, Machine)
	if RunService:IsServer() then
		local isNew = (machine.guid == nil)

		if not isNew then
			self.position = String.convertToVector(self.position)
			self.orientation = String.convertToVector(self.orientation)
		end

		self.owner = owner
		self.userId = owner.UserId
		self.model = assets.Machines:FindFirstChild(self.machineType .. "Machine"):Clone()
		self.model:SetPrimaryPartCFrame(CFrame.new(self.position))
		self.running = false
		self.automation = self.automation or false

		self.buildOptionLabel = self.model.ControlPanel.Chooser.SurfaceGui.TextLabel

		-- TODO: Update machine model based on it's levels

		local buildTypeModule = require(script:FindFirstChild(self.machineType))
		assert(buildTypeModule, "Machine type does not exist")

		self.machineValues = buildTypeModule

		if isNew then
			self.guid = HttpService:GenerateGUID(false)
			RoduxStore:dispatch(addMachine(self.userId, self))
		end

		self.model:SetAttribute("GUID", self.guid)
		self.model.Parent = workspace

		if not isNew and self.buildOption then
			-- TODO: Set Module for build option

			if self.automation then
				self:toggleAutomation(true)
			end
		end

		Machine.playerMachines[tostring(self.userId)][self.guid] = self
		CollectionService:AddTag(self.model, "Machine" .. self.userId)
	else
		if not self.model then
			for _, v in pairs(CollectionService:GetTagged("Machine" .. self.userId)) do
				if v:GetAttribute("GUID") == self.guid then
					self.model = v
				end
			end
		end

		self.machineValues = require(script:FindFirstChild(self.machineType))

		self:setupInteractions()

		Machine.playerMachines[self.guid] = self
	end

	return self
end

function Machine:setupInteractions()
	self.optionPrompt = ProximityPrompt.new({
		parent = self.model:WaitForChild("ControlPanel", 1):WaitForChild("Metal", 1);
		objectText = self.machineType .. " Machine";
		actionText = "Set Build Option";
		enabled = true;
	}, 1)
	self.optionPrompt:connect(function()
		ProximityManager:disable("MachineUI")
		Machine._signal:fire(self)
	end)

	self.actionPrompt = ProximityPrompt.new({
		parent = self.model.Main;
		objectText = self.machineType .. " Machine";
		actionText = (self.automation and "Stop Automation") or (self.speedLevel > 1 and "Start Automation") or "Use Machine";
		enabled = true;
	}, 1)
	self.actionPrompt:connect(function()
		if self.speedLevel > 1 then
			self:toggleAutomation()
		else
			self:useMachine()
		end
	end)
end

function Machine:toggleAutomation(isEnabled)
	if RunService:IsServer() then
		if self.running == isEnabled then return end

		self.running = isEnabled
		RoduxStore:dispatch(editMachineValues(self, "automation", isEnabled))

		if self.running then
			self.startTime = tick()
			-- TODO: Set Buildstage to FullBuild
		else
			self:cancelMachine()
		end
	else
		self.automation = not self.automation
		self.actionPrompt.prompt.ActionText = (self.automation and "Stop Machine") or "Start Machine"
		useMachine:FireServer(self, "toggleAutomation", self.automation)

		if self.automation then
			-- TODO: Loop of useMachine
		else
			self:cancelMachine()
		end
	end
end

function Machine:useMachine()
	if RunService:IsServer() then
		if not self.startTime then
			self.startTime = tick()
		else
			-- TODO: Adjust for BuildStage
			if tick() - self.startTime > self.buildFunctions.minTime then
				self:outputItem()
			end
		end
	else
		-- TODO: Run Step
		useMachine:FireServer(self, "useMachine")
	end
end

function Machine:setBuildOption(option)
	local playerLevels = RoduxStore:waitForValue("playerData", tostring(self.userId), "ResearchLevels")
	if playerLevels[self.machineType] < option then return end

	self.buildOption = option
	if RunService:IsServer() then
		RoduxStore:dispatch(editMachineValues(self, "buildOption", option))
		self.buildOptionLabel.Text = self.machineValues.buildOptions[option].displayName
		self.itemValues = self.machineValues.buildOptions[option]
	else
		useMachine:FireServer(self, "setBuildOption", option)
		self.itemValues = self.machineValues.buildOptions[option]
	end
end

function Machine:upgrade(upgradeType)
	if RunService:IsServer() then
		-- TODO: Check an upgrade still exists
		-- TODO: Transact
		if 1 > 0 then
			self[upgradeType .. "Level"] += 1
			RoduxStore:dispatch(editMachineValues(self, upgradeType .. "Level", self[upgradeType .. "Level"]))
			-- TODO: Update machine model based on it's levels
			return true
		end
	else
		if upgradeMachine:InvokeServer(self, upgradeType) then
			self[upgradeType .. "Level"] += 1
			return true
		end
	end
end

function Machine:outputItem()
	if RunService:IsServer() then
		local outputTime = 5
		task.wait(outputTime)

		print("OutputItem")
	else
		useMachine:FireServer(self, "useMachine")
		-- TODO: Output Tween
		useMachine:FireServer(self, "useMachine")
	end
end

function Machine:cancelMachine()
	if RunService:IsServer() then
		self.startTime = nil
	else
		-- TODO: Cancel Tweens
		-- TODO: Destroy Build items
	end
end

function Machine:_handleTween(tweenInfoFunc, index)
	local info = tweenInfoFunc(self.currentItem)[index]

	if RunService:IsServer() then

	else
		if typeof(info) == "function" then
			info()
		else
			assert(info.object or typeof(info.cframe()) == "table", "Tween must have an object argument.")
			assert(typeof(info.duration) == "number", "Tween must have a duration specified.")
			assert(typeof(info.maxIndex) == "number", "Tween must have a max index specified.")

			local cframeFunc = info.cframe

			local tweenInfo = TweenInfo.new(info.duration, info.easingStyle or Enum.EasingStyle.Linear, info.easingDirection or Enum.EasingDirection.Out)
			local objectTween
			local moveFunctions = {}
			if typeof(info.cframe()) ~= "table" then
				local objects = info.cframe(1)
				for object, _ in pairs(objects) do
					local moveFunction
					-- TODO: Change tweenInfo to allow iteration pre-tween
					-- Ensures 1 less action on render-stepped
				end
			end

			if typeof(info.cframe()) == "table" then

			else
				local object = info.object
				local startCFrame = (object:IsA("BasePart") and object.CFrame) or object.PrimaryPart.CFrame
				local moveFunction

				if object:IsA("BasePart") then
					moveFunction = function(cframe)
						object.CFrame = startCFrame * cframe
					end
				else
					moveFunction = function(cframe)
						object:SetPrimaryPartCFrame(startCFrame * cframe)
					end
				end
				table.insert(moveFunctions, moveFunction)
			end

			objectTween = Tween.new(0, info.maxIndex, tweenInfo, function(value)
				for _, moveFunction in pairs(moveFunctions) do
					moveFunction(value)
				end
			end)
		end
	end
end

-- if typeof(AssembleInfo[index]) == "function" then do the function only
-- If typeof(cframe) == "table" then move the index part
-- If not then assert object ~= nil
-- If typeof(cframe) == "Model/Instance" then Lerp


local function playerAdded(plr)
	if RunService:IsServer() then
		Machine.playerMachines[tostring(plr.UserId)] = {}

		local machineData = RoduxStore:waitForValue("playerData", tostring(plr.UserId), "Machines")

		for _, machine in pairs(machineData) do
			Machine.new(machine, plr)
		end

		task.delay(10, function()
			Machine.new({
				machineType = "Phone";
				position = Vector3.new(871.55, 1.5, 240.896);
				orientation = Vector3.new(0, 0, 0);
				speedLevel = 2;
				qualityLevel = 1;
			}, plr)
		end)
	else
		local machineData = RoduxStore:waitForValue("playerData",tostring(player.UserId), "Machines")
		for _, machine in pairs(machineData) do
			Machine.new(machine, plr)
		end

		CollectionService:GetInstanceAddedSignal("Machine" .. player.UserId):Connect(function(instance)
			machineData = RoduxStore:waitForValue("playerData", tostring(player.UserId), "Machines")
			machineData.model = instance

			local guid = instance:GetAttribute("GUID")
			if guid and machineData[guid] then
				Machine.new(machineData[guid], player)
			end
		end)

		CollectionService:GetInstanceRemovedSignal("Machine" .. player.UserId):Connect(function(instance)
			Machine.playerMachines[instance:GetAttribute("GUID")] = nil
		end)
	end
end

if RunService:IsServer() then
	for _, plr in pairs(Players:GetPlayers()) do
		playerAdded(plr)
	end

	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(function(plr)
		Machine.playerMachines[tostring(plr.UserId)] = nil
	end)

	useMachine.OnServerEvent:Connect(function(plr, _machine, callback, ...)
		if callback ~= "toggleAutomation" and
			callback ~= "upgrade" and
			callback ~= "setBuildOption" and
			callback ~= "useMachine"
		then
			return
		end

		local machine = Machine.playerMachines[tostring(plr.UserId)][_machine.guid]
		if machine then
			Machine[callback](machine, ...)
		end
	end)

	upgradeMachine.OnServerInvoke = function(plr, _machine, upgradeType)
		if not (upgradeType == "speed" or upgradeType == "quality") then return end

		local machine = Machine.playerMachines[tostring(plr.UserId)][_machine.guid]
		if machine then
			return machine:upgrade(upgradeType)
		end
	end
else
	playerAdded()
end

--[[
	Automation Starts a loop
		Start Build option Client, send to server

		Server waits at least min time for second fire
		(Saves firstTime Fired, if Second time Fired > min then accepted, else returns)

		Allow Server to only have 1 wait per machine

		Meanwhile Client does Tween for time, then fires Server
		if automation, server Restarts wait, else it ends

		AlternativeEnabledCondition for ProxPrompt

		TODO: Sort when server is Fired

		TODO: Similar to Chests Only 1 prox prompt at a time
]]

return Machine