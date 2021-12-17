local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local require, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Table = require("Table")
local Chess = require("Chess")
local ChessHandler = require("ChessHandler")
local MouseFuncs = require("Mouse")
local Maid = require("Maid")
local RoduxStore = require("RoduxStore")

local MovePieceEvent = getDataStream("MovePieceEvent", "RemoteEvent")

local ChessClient = {}
local ChangedCells = {}

-- Resets all the values needed during the chess game
function ChessClient.resetValues()
	ChessClient.CurrentGame = nil
	ChessClient.CurrentBoard = nil
	ChessClient.CurrentBoardMaid = nil
	ChessClient.CurrentChessIndex = nil
	ChessClient.SelectedCell = nil
	ChessClient.ValidMoves = nil
	ChessClient.CurrentPlayerNum = nil
	ChessClient.CurrentCol = nil
end

-- Initiates player input to the chess board
function ChessClient.initiateBoardInput(board)
	ChessClient.CurrentBoard = board
    ChessClient.CurrentBoardMaid = Maid.new()
    ChessClient.CurrentBoardMaid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ChessClient.cellClicked(board)
        end
    end))
end

-- Checks if a cell on the board was clicked and does things accordingly
function ChessClient.cellClicked(board)
	ChessClient.resetCellColours()
    local hitCell = MouseFuncs.findHitWithWhitelist(Mouse, board.Cells:GetChildren(), 300)
    if hitCell then
        local cellName = hitCell.Name
        local cellVector = Vector2.new(tonumber(string.sub(cellName, 1, 1)), tonumber(string.sub(cellName, 2)))
		local currentState = RoduxStore:getState().chessState
		if ChessClient.CurrentChessIndex and currentState and currentState[ChessClient.CurrentChessIndex] then
			local info = currentState[ChessClient.CurrentChessIndex]
			local moveIsEven = info.move % 2 == 0
			local abbr, piece = Chess.getCellPiece(info, cellVector)
			local isMyTurn = (ChessClient.CurrentCol == 1 and moveIsEven) or (ChessClient.CurrentCol == 2 and not moveIsEven)
			local isMyPiece = (ChessClient.CurrentCol == 1 and Chess.isWhite(abbr)) or (ChessClient.CurrentCol == 2 and Chess.isBlack(abbr))
			if ChessClient.SelectedCell and ChessClient.ValidMoves and Table.contains(ChessClient.ValidMoves, cellVector) then
				-- Client move piece logic here
				ChessClient.CurrentGame:movePiece(Player, ChessClient.SelectedCell, cellVector)
				MovePieceEvent:FireServer(ChessClient.SelectedCell, cellVector)
				ChessClient.SelectedCell = nil
				ChessClient.ValidMoves = nil
			elseif isMyPiece and piece and cellVector ~= ChessClient.SelectedCell then
				ChessClient.SelectedCell = cellVector
				local validCells = Chess["get" .. piece .. "Moves"](cellVector, info.state, isMyTurn)
				ChessClient.ValidMoves = validCells
				for _, cell in pairs(validCells) do
					local actualCell = board.Cells:FindFirstChild(cell.X .. cell.Y)
					ChessClient.changeCellColour(actualCell)
				end
			else
				ChessClient.SelectedCell = nil
				ChessClient.ValidMoves = nil
			end
		end
    end
end

-- Changes a cells colour and saves its previous colour
function ChessClient.changeCellColour(cell, occupied)
    if ChangedCells[cell] then
        cell.Color = ChangedCells[cell]
        ChangedCells[cell] = nil
    else
        ChangedCells[cell] = cell.Color
        if occupied then
            cell.Color = Color3.fromRGB(255, 166, 0)
        else
            cell.Color = Color3.fromRGB(255, 0, 0)
        end
    end
end

-- Resets all the changed cells colours back to their default colour
function ChessClient.resetCellColours()
    for cell, _ in pairs(ChangedCells) do
        ChessClient.changeCellColour(cell)
    end
end

RoduxStore.changed:connect(function(newState, oldState)
	if newState.chessState and not Table.deepCheckEquality(newState.chessState, oldState.chessState) then
		local oldStateHasGame = false
		local newStateHasGame = false
		for index, _ in pairs(oldState.chessState) do
			if string.find(index, tostring(Player.UserId)) then
				oldStateHasGame = true
				break
			end
		end

		if not oldStateHasGame then
			for index, chessInfo in pairs(newState.chessState) do
				local ind = string.find(index, tostring(Player.UserId))
				if ind then
					ChessClient.CurrentPlayerNum = (ind == 1 and 1) or 2
					local p1Col = chessInfo.p1Col
					local p2Col = (chessInfo.p1Col == 1 and 2) or 1
					local thisCol = (ChessClient.CurrentPlayerNum == 1 and p1Col) or p2Col
					ChessClient.CurrentChessIndex = index
					newStateHasGame = chessInfo
					ChessClient.CurrentCol = thisCol
					ChessClient.CurrentGame = ChessHandler.newGame(chessInfo.p1, chessInfo.p2, chessInfo.board)
					break
				end
			end

			if newStateHasGame ~= false and newStateHasGame.board then
				ChessClient.initiateBoardInput(newStateHasGame.board)
			end
		end
	end
end)

return ChessClient