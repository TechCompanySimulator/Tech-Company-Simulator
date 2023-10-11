local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")

local assets = ReplicatedStorage.Assets
local maids = {}

local PlotSelection = {}
PlotSelection.playerPlotInfo = {}

function PlotSelection.initiate()
	for _, plot in workspace.Plots:GetChildren() do
		PlotSelection.setupPlotSign(plot)
	end

	Players.PlayerRemoving:Connect(PlotSelection.playerRemoving)
end

function PlotSelection.promptTriggered(player, plot)
	if plot:GetAttribute("Taken") or PlotSelection.playerPlotInfo[player] then return end

	plot:SetAttribute("Taken", true)
	maids[plot]:DoCleaning()
	plot:FindFirstChild("FreePlotSign"):Destroy()
	PlotSelection.playerPlotInfo[player] = plot
end

function PlotSelection.setupPlotSign(plot)
	plot:SetAttribute("Taken", nil)
	local freePlotSign = assets.Misc.FreePlotSign:Clone()
	freePlotSign.Parent = plot
	local _, size = freePlotSign:GetBoundingBox()
	freePlotSign:PivotTo(plot.CFrame * CFrame.new(0, plot.Size.Y / 2 + size.Y / 2, plot.Size.Z / 2))

	maids[plot] = Maid.new()
	maids[plot]:GiveTask(freePlotSign.Main.ProximityPrompt.Triggered:Connect(function(player)
		PlotSelection.promptTriggered(player, plot)
	end))
end

function PlotSelection.playerRemoving(player)
	if not PlotSelection.playerPlotInfo[player] then return end
	-- TODO: Clear plot and cleanup plots connections

	PlotSelection.setupPlotSign(PlotSelection.playerPlotInfo[player])
	PlotSelection.playerPlotInfo[player] = nil
end

return PlotSelection