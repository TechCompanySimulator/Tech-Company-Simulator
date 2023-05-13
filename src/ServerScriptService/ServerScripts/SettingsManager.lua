local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local PlayerDataManager = loadModule("PlayerDataManager")

local changeSetting = loadModule("changeSetting")

local changeSettings = getDataStream("ChangeSettings", "RemoteEvent")

local SettingsManager = {
	allowedSettings = {
		DarkMode = true;
	}
}

function SettingsManager:initiate()
	changeSettings.OnServerEvent:Connect(SettingsManager.changeSettings)
end

function SettingsManager.changeSettings(player, setting, value)
	if not setting or value == nil or not SettingsManager.allowedSettings[setting] then return end

	local playerData = RoduxStore:waitForValue("playerData")[tostring(player.UserId)]
	if not playerData then return end
	
	if playerData.Settings and playerData.Settings[setting] == value then return end

	PlayerDataManager:updatePlayerData(player.UserId, changeSetting, setting, value)
end

return SettingsManager