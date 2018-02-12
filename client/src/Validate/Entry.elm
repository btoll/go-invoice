module Validate.Entry exposing (Field, errors)

import Data.Entry exposing (Entry)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Title
    | Date



errors : Entry -> List ( Field, String )
errors entry =
    validate modelValidator entry


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) Entry
modelValidator =
    Validate.all
        [ ifBlank .title ( Title, message)
        , ifBlank .date ( Date, message)
        ]


