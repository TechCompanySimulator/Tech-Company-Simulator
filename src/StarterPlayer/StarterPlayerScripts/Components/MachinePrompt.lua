local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Button = loadModule("Button")
local CloseButton = loadModule("CloseButton")
local Llama = loadModule("Llama")
local MachineSystem = loadModule("MachineSystem")
local Maid = loadModule("Maid")
local React = loadModule("React")
local RoactRodux = loadModule("RoactRodux")
local RoactTemplate = loadModule("RoactTemplate")

local uiTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.MachinePrompt)

local e = React.createElement
local useEffect = React.useEffect
local useRef = React.useRef
local useState = React.useState

local player = Players.LocalPlayer

local function getBuildItemButtons(props : table, machineObj : table) : table
	if not machineObj  or not props.playerResearchLevels then return {} end

	local machineType = machineObj.machineType
	local playerLevel = props.playerResearchLevels[machineType] or 0

	local buttons = {}

	for ind, displayName in props.machineValues[machineType].buildItems do
		local buttonType = if playerLevel >= ind then "Standard" else "Disabled"

		table.insert(buttons, e(Button, {
			buttonProps = {
				Size = UDim2.new(0.8, 0, 0.07, 0);
				LayoutOrder = ind;
			};
			text = displayName;
			buttonType = buttonType;
			onClick = function()
				machineObj:setBuildOption(ind)
			end;
		}))
	end

	return buttons
end

local function getUpgradeButtons(props : table, machineObj : table) : table
	if not machineObj then return {} end

	local machineType = machineObj.machineType
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
				Size = UDim2.new(0.8, 0, 0.07, 0);
				LayoutOrder = 100 + string.len(levelType);
			};
			text = levelType .. " Upgrade " .. level .. ": " .. upgradeDetails.cost .. " " .. upgradeDetails.currency;
			buttonType = "Special";
			onClick = function()
				machineObj:upgradeLevel(levelType)
			end;
		}))
	end

	return buttons
end

local function machinePrompt(props)
	local isEnabled, setEnabled = useState(false)
	local machineObj = useRef()

	useEffect(function()
		local maid = Maid.new()

		maid:giveTask(MachineSystem.openMachinePrompt:connect(function(_machineObj)
			machineObj.current = _machineObj
			setEnabled(true)
		end))

		return function()
			maid:doCleaning()
		end
	end)

	return e(uiTemplate, {
		[RoactTemplate.Root] = 	{
			Visible = props.toggleBinds.MachinePrompt.bind:map(function(bool)
				return bool and isEnabled
			end);
		};

		ButtonFrame = {
			[React.Children] = e(React.Fragment, {}, Llama.List.join(
				getBuildItemButtons(props, machineObj.current),
				getUpgradeButtons(props, machineObj.current)
			));
		};

		CloseButton = e(CloseButton, {
			onClick = function()
				machineObj.current = nil
				setEnabled(false)
			end;
		});
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