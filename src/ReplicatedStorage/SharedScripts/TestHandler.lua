local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Zenith = ReplicatedStorage.ZenithFramework

local loadModule = table.unpack(require(Zenith))

local TestEZ = loadModule("TestEZ")
local CONFIG = loadModule("CONFIG")

if CONFIG.RUN_FRAMEWORK_TESTS then
	local tests = (RunService:IsServer() and Zenith.Tests.Server) or Zenith.Tests.Client
	local sharedResults = TestEZ.TestBootstrap:run(Zenith.Tests.Shared:GetChildren())
	local results = TestEZ.TestBootstrap:run(tests:GetChildren())
end

if CONFIG.RUN_SHARED_TESTS then
	local results = TestEZ.TestBootstrap:run(ReplicatedStorage.SharedTests:GetChildren())
end

if CONFIG.RUN_SERVER_TESTS and RunService:IsServer() then
	local results = TestEZ.TestBootstrap:run(game.ServerScriptService.ServerTests:GetChildren())
end

if CONFIG.RUN_CLIENT_TESTS and RunService:IsClient() then
	local results = TestEZ.TestBootstrap:run(Players.LocalPlayer.PlayerScripts.ClientTests:GetChildren())
end

return {}
