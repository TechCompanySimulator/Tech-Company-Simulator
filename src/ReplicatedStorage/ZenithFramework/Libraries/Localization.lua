local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local setPlayerData = loadModule("setPlayerData")
local setPlayerLanguage = getDataStream("SetPlayerLanguage", "RemoteEvent")

local Localization = {
	sourceLanguageCode = "en";
	languages = {
		"en";
		"fr";
	};
	translators = {};
}

local foundSourceTranslator = pcall(function()
	local sourceTranslator = LocalizationService:GetTranslatorForLocaleAsync(Localization.sourceLanguageCode)
	Localization.translators[Localization.sourceLanguageCode] = sourceTranslator
end)

-- Translates any text to the source language
function Localization.translateToSource(text, object)
	if not object then
		object = game
	end
	if foundSourceTranslator then
		return Localization.translators[Localization.sourceLanguageCode]:Translate(object, text)
	end
	return false
end

-- Translates any text into the given language, if that language is supported
function Localization:translate(text, lang, object)
	if not typeof(lang) == "string" or not table.find(self.languages, lang) then return end
	local translator = self.translators[lang]
	if not translator then
		local _ = pcall(function()
			translator = LocalizationService:GetTranslatorForLocaleAsync(lang)
		end)
	end
	if not translator then return text end
	if not object then
		object = game
	end
	return translator:Translate(object, text)
end

-- Changes the rodux store to reflect the new language, and update UI with the translated text
function Localization.setPlayerLanguage(player, lang)
	if RunService:IsClient() or not typeof(lang) == "string" or not table.find(Localization.languages, lang) then return end
	RoduxStore:dispatch(setPlayerData(player.UserId, "Language", lang))
end

if RunService:IsServer() then
	setPlayerLanguage.OnServerEvent:Connect(Localization.setPlayerLanguage)
end

return Localization