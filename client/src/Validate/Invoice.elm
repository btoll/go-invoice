module Validate.Invoice exposing (errors)

import Data.Invoice exposing (Invoice)
import Validate.Validate exposing (fold, isBlank, isZero)



errors : Invoice -> List String
errors model =
    [ isBlank model.dateFrom "Invoice Date From cannot be blank."
    , isBlank model.dateTo "Invoice Date To cannot be blank."
    , isZero model.rate "Invoice rate cannot be zero."
    ] |> fold


