local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Zenith = ReplicatedStorage.ZenithFramework

local loadModule = table.unpack(require(Zenith))

local TestEZ = loadModule("TestEZ")
local CONFIG = loadModule("CONFIG")

local RanTests = false

local area = (RunService:IsServer() and "server") or "client"

if CONFIG.RUN_FRAMEWORK_TESTS then
	RanTests = true
	local tests = (RunService:IsServer() and Zenith.Tests.Server) or Zenith.Tests.Client
	warn("Framework shared tests started")
	local sharedResults = TestEZ.TestBootstrap:run(Zenith.Tests.Shared:GetChildren())
	warn("Framework shared tests complete")

	warn("Framework " .. area .. " tests started")
	local results = TestEZ.TestBootstrap:run(tests:GetChildren())
	warn("Framework " .. area .. " tests complete")
end

if CONFIG.RUN_SHARED_TESTS then
	RanTests = true
	warn("Shared tests started")
	local results = TestEZ.TestBootstrap:run(ReplicatedStorage.SharedTests:GetChildren())
	warn("Shared tests Complete")
end

if CONFIG.RUN_SERVER_TESTS and RunService:IsServer() then
	RanTests = true
	warn("Server tests started")
	local results = TestEZ.TestBootstrap:run(game.ServerScriptService.ServerTests:GetChildren())
	warn("Server tests Complete")
end

if CONFIG.RUN_CLIENT_TESTS and RunService:IsClient() then
	RanTests = true
	warn("Client tests started")
	local results = TestEZ.TestBootstrap:run(Players.LocalPlayer.PlayerScripts.ClientTests:GetChildren())
	warn("Client tests Complete")
end

if RanTests then
	warn("All " .. area .. " tests complete")
end

return {}
