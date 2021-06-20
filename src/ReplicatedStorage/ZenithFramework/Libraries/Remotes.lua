-- Handles creation and referencing of RemoteEvents and RemoteFunctions
-- Author: TheM0rt0nator

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local RemotesFolder

if RunService:IsServer() then
    RemotesFolder = Instance.new("Folder")
    RemotesFolder.Name = "Remotes"
    RemotesFolder.Parent = ReplicatedStorage
elseif RunService:IsClient() then
    RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
end

-- If server, creates a new remote called remoteName if it doesn't exist
-- If client, returns the remote for use
function Remotes.getRemote(remoteName, remoteType)
    assert(typeof(remoteName) == "string" and (remoteType == "RemoteEvent" or remoteType == "RemoteFunction"))

    if RunService:IsServer() then
        local newRemote = Instance.new(remoteType)
        newRemote.Name = remoteName
        newRemote.Parent = RemotesFolder

        return newRemote
    elseif RunService:IsClient() then
        if RemotesFolder:FindFirstChild(remoteName) then
            return RemotesFolder:FindFirstChild(remoteName)
        end

        warn(remoteName .. " of type " .. remoteType .. " was not found")
    end
end

return Remotes