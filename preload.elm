import Dict


createImages : Dict.Dict String Element
createImages =
  let
    keys = List.map toString [0..8] |> List.append ["redmine", "mine", "button"]
    imagePairs = List.map (\key -> (key, "images/cell/" ++ key ++ ".png" |> image 24 24) ) keys
  in
    Dict.fromList imagePairs


imageDict = createImages

{-
  Another version of drawCell. Images are stored in a Dict (imageDict).
  Didn't really help to speed up image loading.

  TODO: find a way to preload images in Elm
-}

-- Ugly and needs refactoring

drawCell : ViewConfig -> Cell -> LastClick -> Element
drawCell config cell last =
  let
    dummy = image 24 24 "/images/cell/button.png"
    bomb = if cell.position == last then "redmine" else "mine"

  in
      case (cell.state, cell.content) of
        (Covered, _)           -> case Dict.get "button" imageDict of
                                    Nothing -> dummy
                                    Just img -> clickable (Signal.message clicks.address (Click cell.position) ) img
        (Cleared, Mine)        -> case Dict.get bomb imageDict of
                                    Nothing -> dummy
                                    Just img -> img
        (Cleared, Neighbors n) -> case Dict.get (toString n) imageDict of
                                    Nothing -> dummy
                                    Just img -> img
