module Data.Invoice exposing (Invoice, decoder, encoder, manyDecoder, new, succeed)

import Data.Entry exposing (Entry)
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
    , rate : Float
    , totalHours : Float
    , entries : List Entry
    }


new : Invoice
new =
    { id = -1
    , title = ""
    , dateFrom = ""
    , dateTo = ""
    , url = ""
    , comment = ""
    , rate = 0.00
    , totalHours = 0.00
    , entries = []
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
        |> optional "rate" float 0.00
        |> optional "totalHours" float 0.00
        |> optional "entries" ( Data.Entry.decoder |> Decode.list ) []


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
        , ( "rate", Encode.float invoice.rate )
        , ( "totalHours", Encode.float invoice.totalHours )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


