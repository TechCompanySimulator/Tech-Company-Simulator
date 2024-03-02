local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactRodux = loadModule("RoactRodux")
local ResearchSystem = loadModule("ResearchSystem")
local RoactTemplate = loadModule("RoactTemplate")

local Button = loadComponent("Button")

local uiTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.ResearchUI.ResearchOptions)

local e = React.createElement
local player = Players.LocalPlayer

local function getButtons(props : table, levelToResearch: number, isFullyResearched: boolean) : table
	local buttons = {}

	local upgradeCosts = props.upgradeCosts[levelToResearch]

	for ind, priceInfo in upgradeCosts do
		-- Deals with the case where the priceInfo is a table detailing the currency and cost, else it defaults to coins
		local cost = if typeof(priceInfo) == "table" then priceInfo.cost else priceInfo
		local currency = if typeof(cost) == "table" then cost.currency else "Coins"

		table.insert(buttons, e(Button, {
			buttonProps = {
				Name = ind;
				LayoutOrder = ind;
			};
			buttonType = if isFullyResearched or props.progress[ind] then "Disabled" else "Standard"; -- TODO: Change to a confirm disabled one
			text = ind .. ": " .. cost .. " " .. currency;
			onClick = function()
				local success = ResearchSystem.incrementResearch(player, props.machineType, ind)

				if success == false then
					-- TODO: Fire Currency Shop
				end
			end;
		}))
	end

	return buttons
end

-- TODO: Max Level
local function researchOptions(props : table)
	if not props.machineType or not props.level then return end

	local levelToResearch = props.level + 1
	local buildItemName = props.buildItems[levelToResearch]
	local isFullyResearched = false

	-- Deals for the case of when the player has completed all the research for this machine
	-- It will show them the most recent research item
	if not buildItemName then
		isFullyResearched = true
		levelToResearch = props.level
		buildItemName = props.buildItems[levelToResearch]
	end


	return e(uiTemplate, {
		[RoactTemplate.Root] = 	{
			Visible = props.selectedMachine:map(function(value : string) : boolean
				return value == props.machineType
			end);
			Name = props.machineType;
		};

		ButtonFrame = {
			[React.Children] = getButtons(props, levelToResearch, isFullyResearched)
		};

		ResearchItem = {
			Text = buildItemName;
		};
	})
end

researchOptions = RoactRodux.connect(function(state, props)
	if not props.machineType then return {} end

	local playerDataDict = state.playerData or {}
	local playerData = playerDataDict[tostring(player.UserId)] or {}
	local playerResearchData = playerData.ResearchLevels or {}
	local researchData = playerResearchData[props.machineType] or {}

	return {
		progress = researchData.Progress or {};
		level = researchData.Level or 0;
	}

end)(researchOptions)

return researchOptions