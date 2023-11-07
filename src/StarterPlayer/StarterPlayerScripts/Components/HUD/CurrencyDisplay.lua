local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")
local RoactRodux = loadModule("RoactRodux")
local String = loadModule("String")

local coinsDisplay = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.HUD.CoinsDisplay)

local e = React.createElement

local player = Players.LocalPlayer

local function currencyDisplay(props)
	return e(React.Fragment, {}, {
		CoinsDisplay = e(coinsDisplay, {
			[RoactTemplate.Root] = {
				Visible = props.visible;
				Text = "$" .. String.commaFormat(props.currencyData.Coins or 0);
			};
		});
	})
end

currencyDisplay = RoactRodux.connect(function(state)
	local playerData = state.playerData or {}
	local playersData = playerData[tostring(player.UserId)] or {}
	local currencyData = playersData.Currencies or {}

	return {
		currencyData = currencyData;
	}
end)(currencyDisplay)

return currencyDisplay