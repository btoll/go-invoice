module Data.Invoice exposing (Invoice, decoder, encoder, manyDecoder, new, succeed)

import Data.Entry exposing (Entry)
import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Invoice =
    { id : Int
    , company_id: Int
    , dateFrom : String
    , dateTo : String
    , url : String
    , notes : String
    , rate : Float
    , paid : Bool
    , totalHours : Float
    , entries : List Entry
    }


new : Invoice
new =
    { id = -1
    , company_id = -1
    , dateFrom = ""
    , dateTo = ""
    , url = ""
    , notes = ""
    , rate = 0.00
    , paid = False
    , totalHours = 0.00
    , entries = []
    }


decoder : Decoder Invoice
decoder =
    decode Invoice
        |> required "id" int
        |> required "company_id" int
        |> required "dateFrom" string
        |> required "dateTo" string
        |> optional "url" string ""
        |> optional "notes" string ""
        |> optional "rate" float 0.00
        |> optional "paid" bool False
        |> optional "totalHours" float 0.00
        |> optional "entries" ( Data.Entry.decoder |> Decode.list ) []


manyDecoder : Decoder ( List Invoice )
manyDecoder =
    list decoder


encoder : Invoice -> Encode.Value
encoder invoice =
    Encode.object
        [ ( "id", Encode.int invoice.id )
        , ( "company_id", Encode.int invoice.company_id )
        , ( "dateFrom", Encode.string invoice.dateFrom )
        , ( "dateTo", Encode.string invoice.dateTo )
        , ( "url", Encode.string invoice.url )
        , ( "notes", Encode.string invoice.notes )
        , ( "rate", Encode.float invoice.rate )
        , ( "paid", Encode.bool invoice.paid )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


