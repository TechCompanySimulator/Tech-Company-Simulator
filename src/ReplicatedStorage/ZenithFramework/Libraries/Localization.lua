local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local setPlayerLanguage = loadModule("setPlayerLanguage")

local setPlayerLanguageEvent = getDataStream("SetPlayerLanguage", "RemoteEvent")

local Localization = {
	translators = {};
	sourceLanguageCode = "en";
	languages = {
		"en";
		"fr";
	};
}

local foundSourceTranslator = pcall(function()
	local sourceTranslator = LocalizationService:GetTranslatorForLocaleAsync(Localization.sourceLanguageCode)

	Localization.translators[Localization.sourceLanguageCode] = sourceTranslator
end)

-- Translates any text to the source language
function Localization.translateToSource(text, object)
	object = if object then object else game

	if foundSourceTranslator then
		return Localization.translators[Localization.sourceLanguageCode]:Translate(object, text)
	end

	return false
end

-- Translates any text into the given language, if that language is supported
function Localization:translate(text, lang, object)
	if not typeof(lang) == "string" or not table.find(self.languages, lang) then return end

	local translator = self.translators[lang]
	object = if object then object else game

	if not translator then
		local _ = pcall(function()
			translator = LocalizationService:GetTranslatorForLocaleAsync(lang)
		end)
	end

	if not translator then return text end

	return translator:Translate(object, text)
end

-- Changes the rodux store to reflect the new language, and update UI with the translated text
function Localization.setPlayerLanguage(player, lang)
	if RunService:IsClient()
		or typeof(lang) ~= "string"
		or not table.find(Localization.languages, lang)
	then
		return
	end

	RoduxStore:dispatch(setPlayerLanguage(player.UserId, lang))
end

if RunService:IsServer() then
	setPlayerLanguageEvent.OnServerEvent:Connect(Localization.setPlayerLanguage)
end

return Localization