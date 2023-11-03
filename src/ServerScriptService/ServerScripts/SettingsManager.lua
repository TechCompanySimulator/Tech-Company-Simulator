local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local PlayerDataManager = loadModule("PlayerDataManager")
local changePlayerSetting = loadModule("changePlayerSetting")

local changeSettingsEvent = getDataStream("ChangeSettings", "RemoteEvent")

local SettingsManager = {
	allowedSettings = {
		DarkMode = true;
	}
}

function SettingsManager:initiate()
	changeSettingsEvent.OnServerEvent:Connect(SettingsManager.changePlayerSetting)
end

function SettingsManager.isValidSetting(setting : string, value : any) : boolean
	local settingAllowed = SettingsManager.allowedSettings[setting]
	local settingType = if settingAllowed then typeof(settingAllowed) else nil

	return settingAllowed ~= nil and typeof(value) == settingType
end

function SettingsManager.changePlayerSetting(player : Player, setting : string, value : any) : boolean
	if not SettingsManager.isValidSetting(setting, value) then return end

	local playerData = RoduxStore:waitForValue("playerData")[tostring(player.UserId)]

	if not playerData or (playerData.Settings and playerData.Settings[setting] == value) then
		return false
	end

	PlayerDataManager:updatePlayerData(player.UserId, changePlayerSetting, setting, value)

	return true
end

return SettingsManager