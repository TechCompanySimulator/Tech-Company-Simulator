-- Zenith Framework
-- Author: TheM0rt0nator

local RunService = game:GetService("RunService")

local ModuleScriptLoader = require(script.ModuleScriptLoader)
local DataStreamHandler = require(script.DataStreamHandler)

local Framework = {}

if RunService:IsServer() then
    local newLoader = ModuleScriptLoader.new("Server")
    local dataStreamHandler = DataStreamHandler.new()

    return {newLoader, dataStreamHandler}
elseif RunService:IsClient() then
    local newLoader = ModuleScriptLoader.new("Client")
    local dataStreamHandler = DataStreamHandler.new()

    return {newLoader, dataStreamHandler}
end

return Framework