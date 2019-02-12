module Data.Company exposing (Company, decoder, encoder, manyDecoder, new, succeed)

import Data.Invoice exposing (Invoice)
import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Company =
    { id : Int
    , name : String
    , contact : String
    , street1 : String
    , street2 : String
    , city : String
    , state : String
    , zip : String
    , url : String
    , notes : String
    , invoices : List Invoice
    }


new : Company
new =
    { id = -1
    , name = ""
    , contact = ""
    , street1 = ""
    , street2 = ""
    , city = ""
    , state = ""
    , zip = ""
    , url = ""
    , notes = ""
    , invoices = []
    }


decoder : Decoder Company
decoder =
    decode Company
        |> required "id" int
        |> required "name" string
        |> required "contact" string
        |> required "street1" string
        |> required "street2" string
        |> required "city" string
        |> required "state" string
        |> required "zip" string
        |> required "url" string
        |> required "notes" string
        |> optional "invoices" ( Data.Invoice.decoder |> Decode.list ) []


manyDecoder : Decoder ( List Company )
manyDecoder =
    list decoder


encoder : Company -> Encode.Value
encoder company =
    Encode.object
        [ ( "id", Encode.int company.id )
        , ( "name", Encode.string company.name )
        , ( "contact", Encode.string company.contact )
        , ( "street1", Encode.string company.street1 )
        , ( "street2", Encode.string company.street2 )
        , ( "city", Encode.string company.city )
        , ( "state", Encode.string company.state )
        , ( "zip", Encode.string company.zip )
        , ( "url", Encode.string company.url )
        , ( "notes", Encode.string company.notes )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


