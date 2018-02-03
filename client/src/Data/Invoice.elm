module Data.Invoice exposing (Invoice, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Invoice =
    { id : Int
    , title : String
    , dateFrom : String
    , dateTo : String
    , url : String
    , comment : String
    , totalHours : Float
    }


new : Invoice
new =
    { id = -1
    , title = ""
    , dateFrom = ""
    , dateTo = ""
    , url = ""
    , comment = ""
    , totalHours = 0.00
    }


decoder : Decoder Invoice
decoder =
    decode Invoice
        |> required "id" int
        |> optional "title" string ""
        |> required "dateFrom" string
        |> required "dateTo" string
        |> optional "url" string ""
        |> optional "comment" string ""
        |> optional "totalHours" float 0.00


manyDecoder : Decoder ( List Invoice )
manyDecoder =
    list decoder


encoder : Invoice -> Encode.Value
encoder invoice =
    Encode.object
        [ ( "id", Encode.int invoice.id )
        , ( "title", Encode.string invoice.title )
        , ( "dateFrom", Encode.string invoice.dateFrom )
        , ( "dateTo", Encode.string invoice.dateTo )
        , ( "url", Encode.string invoice.url )
        , ( "comment", Encode.string invoice.comment )
        , ( "totalHours", Encode.float invoice.totalHours )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


