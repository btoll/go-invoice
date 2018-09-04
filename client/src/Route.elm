module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = Home
    | Company
    | Invoice
    | Entry


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map Company (s "company")
        , Url.map Entry (s "entry")
        , Url.map Invoice (s "invoice")
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Company ->
                    [ "company" ]

                Invoice ->
                    [ "invoice" ]

                Entry ->
                    [ "entry" ]
    in
        "#/" ++ String.join "/" pieces



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location


