module Validate.Company exposing (errors)

import Data.Company exposing (Company)
import Validate.Validate exposing (fold, isBlank)



errors : Company -> List String
errors model =
    [ isBlank model.name "Company name cannot be blank."
    , isBlank model.contact "Company contact cannot be blank."
    ] |> fold


