-- Zenith Framework
-- Author: TheM0rt0nator

local RunService = game:GetService("RunService")

local ModuleScriptLoader = require(script.ModuleScriptLoader)
local DataStreamHandler = require(script.DataStreamHandler)

local newLoader = ModuleScriptLoader.new(RunService:IsServer() and "Server" or "Client")
local dataStreamHandler = DataStreamHandler.new()
local componentLoader = RunService:IsClient() and ModuleScriptLoader.new("Client", "Components")

return {newLoader, dataStreamHandler, componentLoader}