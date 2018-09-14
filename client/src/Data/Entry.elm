module Data.Entry exposing (Entry, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Entry =
    { id : Int
    , invoice_id : Int      -- Foreign key.
    , title : String
    , date : String
    , reference : String
    , comment : String
    , hours : Float
    }


new : Entry
new =
    { id = -1
    , invoice_id = -1
    , title = ""
    , date = ""
    , reference = ""
    , comment = ""
    , hours = 0.00
    }


decoder : Decoder Entry
decoder =
    decode Entry
        |> required "id" int
        |> required "invoice_id" int
        |> optional "title" string ""
        |> required "date" string
        |> optional "reference" string ""
        |> optional "comment" string ""
        |> optional "hours" float 0.00


manyDecoder : Decoder ( List Entry )
manyDecoder =
    list decoder


encoder : Entry -> Encode.Value
encoder entry =
    Encode.object
        [ ( "id", Encode.int entry.id )
        , ( "invoice_id", Encode.int entry.invoice_id )
        , ( "title", Encode.string entry.title )
        , ( "date", Encode.string entry.date )
        , ( "reference", Encode.string entry.reference )
        , ( "comment", Encode.string entry.comment )
        , ( "hours", Encode.float entry.hours )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


