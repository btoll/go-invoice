module Validate.Invoice exposing (Field, errors)

import Data.Invoice exposing (Invoice)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Title
    | DateFrom
    | DateTo
--    | Rate



errors : Invoice -> List ( Field, String )
errors invoice =
    validate modelValidator invoice


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) Invoice
modelValidator =
    Validate.all
        [ ifBlank .title ( Title, message)
        , ifBlank .dateFrom ( DateFrom, message)
        , ifBlank .dateTo ( DateTo, message)
--        , ifBlank .rate ( Rate, message)
        ]


