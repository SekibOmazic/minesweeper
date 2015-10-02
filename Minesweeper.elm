module Minesweeper where


import Color exposing (red, blue, white, purple)
import Graphics.Element exposing (..)
import Graphics.Input exposing (clickable)

import Signal

import Random exposing (..)
import Text
---------
-- Model
---------

-- constants
numberOfMines = 40
offset = (20, 20)
space  = 2
boardDimensions = (16, 16)

-- config
-- TODO: get screen dimensions as Window.dimensions
type alias ViewConfig = { screenDimensions : (Int, Int) }

initConfig = { screenDimensions = (500, 600) }


type Action = Click (Int, Int) | Resize (Int, Int) | ResetGame

-- Cell
type CellState  = Cleared | Covered
type Content    = Mine | Neighbors Int
type alias Cell = {   position : (Int, Int)
                    , state    : CellState
                    , content  : Content  }

type alias LastClick = (Int, Int)

-- Board
type alias Board = List (List Cell)

-- Game
type GameState  = Won | Lost | Playing
type alias Game = (GameState, Board, LastClick, Seed)


createBoard: Int -> Int -> Board
createBoard rows cols =
  let
    createCell x y = {   position = (x, y)
                       , state    = Covered
                       , content  = Neighbors 0  }

  in
    List.map (\row -> (List.map (\col -> createCell row col) [1..cols])) [1..rows]


neighbors : (Int, Int) -> List (Int, Int)
neighbors (x, y) =
    [ (x-1,y-1), (x,y-1), (x+1,y-1),
      (x-1,y),            (x+1,y),
      (x-1,y+1), (x,y+1), (x+1,y+1) ]


countMines : Cell -> Board -> Int
countMines cell board =
  let
    mineCount (x,y) = if isCellMined (x,y) board then 1 else 0

  in
    List.foldl (+) 0 <| List.map mineCount <| neighbors cell.position
    -- List.foldl (+) 0 (List.map mineCount <| neighbors cell.position)


calculateNeighbors : Board -> Board
calculateNeighbors board =
  let
    updateCellNeighbors cell =
      if cell.content == Mine
        then cell
        else { cell | content <- Neighbors (countMines cell board) }

  in
    List.map (\row -> List.map updateCellNeighbors row) board


generateBoard : Int -> Int -> Int -> Seed -> Game
generateBoard rows cols nMines seed =
  let
    dummyBoard = createBoard rows cols
    (minefield, newSeed) = placeMines nMines dummyBoard seed
    minefieldWithNeighbors = calculateNeighbors minefield

  in
    (Playing, minefieldWithNeighbors, (0,0), newSeed)


boardRows : Board -> Int
boardRows board = List.length board


boardCols : Board -> Int
boardCols board = List.length (Maybe.withDefault [] (List.head board))


placeMines : Int -> Board -> Seed -> (Board, Seed)
placeMines n board seed =
  if n == 0
    then
      (calculateNeighbors board, seed)
    else
      let
        (mineX, seed1) = generate (int 1 (boardRows board)) seed
        (mineY, seed2) = generate (int 1 (boardCols board)) seed1
      in
        if (isCellMined (mineX, mineY) board)
          then placeMines n board seed2 -- cell already mined, try again
          else placeMines (n-1) (placeMine mineX mineY board) seed2


placeMine : Int -> Int -> Board -> Board
placeMine x y board =
  let
    mineCell cell =
      if cell.position == (x,y)
        then { cell | content <- Mine }
        else cell

  in
    List.map (\row -> List.map mineCell row) board


takeCell : (Int, Int) -> Board -> Maybe Cell
takeCell (x, y) board =
  let
    flat = List.concat board
    found = List.filter (\cell -> cell.position == (x,y)) flat

  in
    case found of
      []     -> Nothing
      hd::tl -> Just hd


cellStateAndContent : (Int, Int) -> Board -> (CellState, Content)
cellStateAndContent (x,y) board =
  case takeCell (x, y) board of
    Just aCell -> (aCell.state, aCell.content)
    Nothing    -> (Cleared, Neighbors 0)


isCellMined : (Int, Int) -> Board -> Bool
isCellMined (x, y) board =
    case takeCell (x, y) board of
      Nothing -> False
      Just c  -> c.content == Mine


safeClicks : Board -> Int
safeClicks board =
  let
    flat = List.concat board

    add cell sum =
      if cell.content == Mine || cell.state == Cleared
        then sum
        else sum + 1

  in
    List.foldl add 0 flat


clearCell : (Int, Int) -> Board -> Board
clearCell (x,y) board =
  List.map (\row -> List.map (\cell -> if cell.position == (x,y) then { cell | state <- Cleared } else cell) row) board
  {- SAME AS ABOVE BUT MORE READABLE
  let
    clearCell cell =
       if cell.position == (x,y)
          then { cell | state <- Cleared }
          else cell
  in
    List.map (\row -> List.map clearCell row) board
  -}


clearBoard : Board -> Board
clearBoard board =
  List.map (\row -> (List.map (\cell -> { cell | state <- Cleared }) row) ) board


clearCellAndNeighbors : List (Int, Int) -> Board -> Board
clearCellAndNeighbors cells board =
  case cells of
    []          -> board
    (x,y)::rest -> case (cellStateAndContent (x,y) board) of
        (Cleared, _)           -> clearCellAndNeighbors rest board
        (Covered, Mine)        -> clearCellAndNeighbors rest board
        (Covered, Neighbors 0) -> let newList = List.append (neighbors (x,y)) rest in clearCellAndNeighbors newList <| clearCell (x, y) board
        (Covered, Neighbors n) -> clearCellAndNeighbors rest <| clearCell (x, y) board



--------
-- View
--------

drawCell : ViewConfig -> Cell -> LastClick -> Element
drawCell config cell last =
  let
    square = image 24 24
    bomb = if cell.position == last then "redmine.png" else "mine.png"

    coveredCell = square <| "images/cell/button.png"

    clearedCell = case cell.content of
      Mine        -> square <| "images/cell/" ++ bomb
      Neighbors n -> square <| "images/cell/" ++ (toString n) ++ ".png"

  in
    case cell.state of
      Cleared -> clearedCell
      _       -> clickable (Signal.message clicks.address (Click cell.position) ) coveredCell


drawRow : ViewConfig -> List Cell -> LastClick -> Element
drawRow config row last =
  flow right (List.map (\cell -> drawCell config cell last) row)


drawBoard : ViewConfig -> Board -> LastClick -> Element
drawBoard config board last =
  flow down (List.map (\row -> drawRow config row last) board)


drawButton : GameState -> Element
drawButton gameState =
  let
    png = case gameState of
      Won  -> "images/face/victory.png"
      Lost -> "images/face/oh.png"
      _    -> "images/face/defeat.png"

    msg = Text.fromString "Click to restart" |> Text.color white |> Text.height 24
    buttonWithText = flow right [image 32 32 png,  msg |> rightAligned |> width 330]
    header = buttonWithText |> container 384 48 middle |> color purple

  in
    clickable (Signal.message clicks.address ResetGame) header


view : ViewConfig -> Game -> Element
view config (gameState, board, last, seed) =
     flow down [
            drawButton gameState,
            drawBoard config board last
         ]

----------
-- Update
----------
update : Action -> Game -> Game
update action (gameState, board, last, seed) =
  case action of
    ResetGame ->
      generateBoard (fst boardDimensions) (snd boardDimensions) numberOfMines seed

    Click (x, y) ->
      let
        (cellState, cellContent) = cellStateAndContent (x,y) board

        restCells = safeClicks board

      in
        case (cellState, cellContent, restCells) of
          (Covered, Mine, _) -> (Lost, clearBoard board, (x,y), seed)
          (Covered, _,    1) -> (Won,  clearBoard board, (x,y), seed)
          _                  -> (Playing, clearCellAndNeighbors [(x,y)] board, (x,y), seed)


-- Signals
clicks : Signal.Mailbox Action
clicks = Signal.mailbox ResetGame

userClicks : Signal Action
userClicks = clicks.signal


-- TODO: add Windows.dimensions
viewConfig : Signal ViewConfig
viewConfig = Signal.constant initConfig


main : Signal Element
main =
  let
    initialGame = generateBoard (fst boardDimensions) (snd boardDimensions) numberOfMines (initialSeed 12345)

  in
    Signal.map2 view viewConfig (Signal.foldp update initialGame userClicks)
