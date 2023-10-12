local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local MachineSystem = loadModule("MachineSystem")
local Maid = loadModule("Maid")
local React = loadModule("React")
local RoactRodux = loadModule("RoactRodux")
local RoactTemplate = loadModule("RoactTemplate")
local Button = loadComponent("Button")
local CloseButton = loadComponent("CloseButton")

local uiTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.MachinePrompt)

local e = React.createElement
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

local player = Players.LocalPlayer

local function getBuildItemButtons(props : table, machineObj : table) : table
	if not machineObj  or not props.playerResearchLevels then return {} end

	local machineType = string.lower(machineObj.machineType)
	local playerLevel = props.playerResearchLevels[machineType] or 0

	local buttons = {}

	for ind, displayName in props.machineValues[machineType].buildItems do
		local buttonType = if playerLevel >= ind then "Standard" else "Disabled"

		table.insert(buttons, e(Button, {
			buttonProps = {
				Size = UDim2.new(0.8, 0, 0.14, 0);
			};
			text = displayName;
			onClick = function()
				machineObj:setBuildOption(ind)
			end;
		}))
	end

	return buttons
end

local function getUpgradeButtons(props : table, machineObj : table) : table
	warn(machineObj)
	if not machineObj then return {} end

	local machineType = string.lower(machineObj.machineType)
	local levels = {
		Speed = machineObj.speedLevel;
		Quality = machineObj.qualityLevel;
	}

	local buttons = {}

	for levelType, level in levels do
		local upgradeValues = props.machineValues[machineType][string.lower(levelType) .. "Upgrades"]
		local upgradeDetails = upgradeValues[level]

		-- If there are no further upgrades for the current level then don't create the button
		if not upgradeDetails then continue end

		table.insert(buttons, e(Button, {
			buttonProps = {
				Size = UDim2.new(0.8, 0, 0.14, 0);
				LayoutOrder = 100 + string.len(levelType);
			};
			text = levelType .. " Upgrade " .. level .. ": " .. upgradeDetails.cost .. " " .. upgradeDetails.currency;
			buttonType = "Special";
			onClick = function()
				machineObj:upgradeLevel(string.lower(levelType))
			end;
		}))
	end

	return buttons
end

local function machinePrompt(props)
	local state, setState = useState(false)
	local machineObj = useRef()
	local toggleBinds = props.toggleBinds.MachinePrompt

	useEffect(function()
		local maid = Maid.new()

		maid:giveTask(MachineSystem.openMachinePrompt:connect(function(_machineObj)
			machineObj.current = _machineObj
			toggleBinds.setBind(true)
			setState(true)
		end))

		return function()
			maid:doCleaning()
		end
	end)

	return e(uiTemplate, {
		[RoactTemplate.Root] = 	{
			Visible = toggleBinds.bind:map(function(bool)
				return bool and props.visible
			end);

			[React.Children] = {
				CloseButton = e(CloseButton, {
					onClick = function()
						machineObj.current = nil
						toggleBinds.setBind(false)
						setState(false)
					end;
				});
			};
		};

		Title = {
			Text = (machineObj.current and machineObj.current.machineType or "") .. " Machine";
		};

		ButtonFrame = {
			[React.Children] = Llama.List.join(
				getBuildItemButtons(props, machineObj.current),
				getUpgradeButtons(props, machineObj.current)
			);
		};
	})
end

machinePrompt = RoactRodux.connect(function(state)
	local playerDataDict = state.playerData or {}
	local playerData = playerDataDict[tostring(player.UserId)] or {}
	local playerResearchLevels = playerData.ResearchLevels or {}

	local machineValues = state.gameValues.machines or {}

	return {
		playerResearchLevels = playerResearchLevels;
		machineValues = machineValues;
	}
end)(machinePrompt)

return machinePrompt