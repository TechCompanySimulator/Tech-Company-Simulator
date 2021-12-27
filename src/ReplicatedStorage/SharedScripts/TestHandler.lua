local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local TestEZ = loadModule("TestEZ")
local CONFIG = loadModule("CONFIG")

if CONFIG.RUN_SHARED_TESTS then
	warn("Running shared tests")
	TestEZ.run(ReplicatedStorage.SharedTests, function(results)
		for _, err in pairs(results.errors) do
			warn(err)
		end
	end)
	warn("Shared tests complete")
end

if CONFIG.RUN_SERVER_TESTS and RunService:IsServer() then
	warn("Running server tests")
	TestEZ.run(game.ServerScriptService.ServerTests, function(results)
		for _, err in pairs(results.errors) do
			warn(err)
		end
	end)
	warn("Server tests complete")
end

if CONFIG.RUN_CLIENT_TESTS and RunService:IsClient() then
	warn("Running client tests")
	local Player = Players.LocalPlayer

	TestEZ.run(Player.PlayerScripts.ClientTests, function(results)
		for _, err in pairs(results.errors) do
			warn(err)
		end
	end)
	warn("Client tests complete")
end
