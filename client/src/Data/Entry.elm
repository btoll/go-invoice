module Data.Entry exposing (Entry, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Entry =
    { id : Int
    , invoice_id : Int      -- Foreign key.
    , title : String
    , date : String
    , reference : List String
    , notes : String
    , hours : Float
    }


new : Entry
new =
    { id = -1
    , invoice_id = -1
    , title = ""
    , date = ""
    , reference = []
    , notes = ""
    , hours = 0.00
    }


decoder : Decoder Entry
decoder =
    decode Entry
        |> required "id" int
        |> required "invoice_id" int
        |> optional "title" string ""
        |> required "date" string
        |> optional "reference" ( string |> Decode.list ) []
        |> optional "notes" string ""
        |> optional "hours" float 0.00


manyDecoder : Decoder ( List Entry )
manyDecoder =
    list decoder


encoder : Entry -> Encode.Value
encoder entry =
    Encode.object
        [ ( "id",  entry.id |> Encode.int )
        , ( "invoice_id", entry.invoice_id |> Encode.int )
        , ( "title", entry.title |> Encode.string )
        , ( "date", entry.date |> Encode.string )
        , ( "reference", entry.reference |> manyReferencesEncoder >> Encode.list )
        , ( "notes", entry.notes |> Encode.string )
        , ( "hours", entry.hours |> Encode.float )
        ]


manyReferencesEncoder : List String -> List Encode.Value
manyReferencesEncoder references =
    references
        |> List.map Encode.string


succeed : a -> Decoder a
succeed =
    Decode.succeed


