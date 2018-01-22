module Data.Invoice exposing (Invoice, decoder, encoder, manyDecoder, succeed)

import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Invoice =
    { id : Int
    , date : String
    , title : String
    , url : String
    , comment : String
    , hours : Float
    }


decoder : Decoder Invoice
decoder =
    decode Invoice
        |> required "id" int
        |> optional "date" string ""
        |> optional "title" string ""
        |> optional "url" string ""
        |> optional "comment" string ""
        |> optional "hours" float 0.00


manyDecoder : Decoder ( List Invoice )
manyDecoder =
    list decoder


encoder : Invoice -> Encode.Value
encoder invoice =
    Encode.object
        [ ( "id", Encode.int invoice.id )
        , ( "date", Encode.string invoice.date )
        , ( "title", Encode.string invoice.title )
        , ( "url", Encode.string invoice.url )
        , ( "comment", Encode.string invoice.comment )
        , ( "hours", Encode.float invoice.hours )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


