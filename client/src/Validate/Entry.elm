module Validate.Entry exposing (errors)

import Data.Entry exposing (Entry)
import Validate.Validate exposing (fold, isBlank, isZero)



errors : Entry -> List String
errors model =
    [ isBlank model.title "Entry title cannot be blank."
    , isBlank model.date "Entry date cannot be blank."
    , isZero model.hours "Entry hours contact cannot be zero."
    ] |> fold


