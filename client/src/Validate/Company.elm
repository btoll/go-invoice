module Validate.Company exposing (Field, errors)

import Data.Company exposing (Company)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Title
    | DateFrom
    | DateTo
--    | Rate



errors : Company -> List ( Field, String )
errors company =
    validate modelValidator company


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) Company
modelValidator =
    Validate.all
        [ ifBlank .name ( Title, message)
--        , ifBlank .rate ( Rate, message)
        ]


