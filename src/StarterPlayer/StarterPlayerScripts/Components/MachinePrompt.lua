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
local useBinding = React.useBinding
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useState = React.useState

local player = Players.LocalPlayer

local function getBuildItemButtons(props: table, machineObj: table, reactProps: table): table
	if not machineObj  or not props.playerResearchData then return {} end

	local machineType = string.lower(machineObj.machineType)
	local playerLevel = props.playerResearchData[machineType].Level or 0

	local buttons = {}

	for ind, displayName in props.machineValues[machineType].buildItems do
		table.insert(buttons, e(Button, {
			buttonProps = {
				Size = UDim2.new(0.8, 0, 0.14, 0);
			};
			text = displayName;
			buttonType = reactProps.buildItem:map(function(value: number?): string
				local isSelected = value == ind

				return if isSelected then "Special"
					elseif playerLevel >= ind then "Confirm"
					elseif ind == playerLevel + 1 then "Standard"
					else "Disabled"
			end);
			onClick = function(): nil
				local success = machineObj:setBuildOption(ind)

				if success then
					reactProps.setSelectedBuildItem(ind)
				end
			end;
		}))
	end

	return buttons
end

local function getUpgradeButtons(props: table, machineObj: table, setState: Function): table
	if not machineObj then return {} end

	local machineType = string.lower(machineObj.machineType)
	local levels = {
		Speed = machineObj.speedLevel;
		Quality = machineObj.qualityLevel;
	}

	local buttons = {}

	for levelType, level in levels do
		-- Upgrade costs are indexed from 1 onwards, with 1 representing costs for level 2 etc
		local upgradeValues = props.machineValues[machineType:lower()][levelType:lower() .. "Upgrades"]
		local upgradeDetails = upgradeValues[level]

		-- If there are no further upgrades for the level type then don't create the button
		if not upgradeDetails then continue end

		table.insert(buttons, e(Button, {
			buttonProps = {
				Size = UDim2.new(0.8, 0, 0.14, 0);
				LayoutOrder = 100 + levelType:len();
			};
			text = levelType .. " Upgrade " .. level .. ": " .. upgradeDetails.cost .. " " .. upgradeDetails.currency;
			buttonType = "Special";
			debounce = 0.2;
			onClick = function(): nil
				local success = machineObj:upgradeLevel(levelType:lower())

				if success then
					setState({})
				end
			end;
		}))
	end

	return buttons
end

local function getMemoLevels(playerResearchData: table, machineObj: table): table
	local levels = {}

	for researchType, researchData in playerResearchData do
		table.insert(levels, researchType .. researchData.Level)
	end

	if machineObj then
		table.insert(levels, "Speed" .. machineObj.speedLevel)
		table.insert(levels, "Quality" .. machineObj.qualityLevel)
	end

	return table.unpack(levels)
end

local function machinePrompt(props: table): table
	local machineObj = useRef()
	local toggleBinds = props.toggleBinds.MachinePrompt

	local _, setState = useState()
	local buildItem, setSelectedBuildItem = useBinding()

	useEffect(function(): Function
		local maid = Maid.new()

		maid:giveTask(MachineSystem.machinePromptSignal:connect(function(_machineObj: table): nil
			machineObj.current = _machineObj
			setSelectedBuildItem(_machineObj.buildOption)
			toggleBinds.setBind(true)
			setState({})
		end))

		return function(): nil
			maid:doCleaning()
		end
	end)

	local prompt = useMemo(function(): table
		return e(uiTemplate, {
			[RoactTemplate.Root] = 	{
				Visible = toggleBinds.bind:map(function(bool: boolean): boolean
					return bool and props.visible
				end);

				[React.Children] = {
					CloseButton = e(CloseButton, {
						onClick = function(): nil
							machineObj.current = nil
							toggleBinds.setBind(false)
							setSelectedBuildItem(nil)
						end;
					});
				};
			};

			Title = {
				Text = (machineObj.current and machineObj.current.machineType or "") .. " Machine";
			};

			ButtonFrame = {
				[React.Children] = Llama.List.join(
					getBuildItemButtons(props, machineObj.current, {
						buildItem = buildItem;
						setSelectedBuildItem = setSelectedBuildItem;
					}),
					getUpgradeButtons(props, machineObj.current, setState)
				);
			};
		})
	end, {props.visible, machineObj.current, props.machineValues, getMemoLevels(props.playerResearchData, machineObj.current)})

	return prompt
end

machinePrompt = RoactRodux.connect(function(state: table): table
	local playerDataDict = state.playerData or {}
	local playerData = playerDataDict[tostring(player.UserId)] or {}
	local playerResearchData = playerData.ResearchLevels or {}

	local gameValues = state.gameValues or {}
	local machineValues = gameValues.machines or {}

	return {
		playerResearchData = playerResearchData;
		machineValues = machineValues;
	}
end)(machinePrompt)

return machinePrompt