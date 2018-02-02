module Util.Date exposing (parse, rfc3339, simple)

import Date exposing (Date)
import Dict exposing (Dict)



type alias Parsed =
    { year : String
    , month : String
    , day : String
    , hour : String
    , minute : String
    }


fromMonth : Dict String String
fromMonth =
    Dict.fromList
    [
        ( "Jan", "01" )
        , ( "Feb", "02" )
        , ( "Mar", "03" )
        , ( "Apr", "04" )
        , ( "May", "05" )
        , ( "Jun", "06" )
        , ( "Jul", "07" )
        , ( "Aug", "08" )
        , ( "Sep", "09" )
        , ( "Oct", "10" )
        , ( "Nov", "11" )
        , ( "Dec", "12" )
    ]


parse : Date -> Parsed
parse date =
    let
        year = toString ( Date.year date )

        month = toString ( Date.month date )
        mo = Dict.get month fromMonth |> Maybe.withDefault "--"

        day = toString ( Date.day date )
        d = if ( day |> String.length ) == 1 then ( (++) "0" day ) else day

        hour = toString ( Date.hour date )
        h = if ( hour |> String.length ) == 1 then ( (++) "0" hour ) else hour

        minute = toString ( Date.minute date )
        min = if ( minute |> String.length ) == 1 then ( (++) "0" minute ) else minute
    in
        { year = year
        , month = mo
        , day = d
        , hour = h
        , minute = min
        }


rfc3339 : Date -> String
rfc3339 date =
    let
        h = date |> parse
    in
    h.year ++ "-" ++ h.month ++ "-" ++ h.day ++ "T" ++ h.hour ++ ":" ++ h.minute ++ ":00+00:00"



simple : Date -> String
simple date =
    let
        h = date |> parse
    in
    h.year ++ "/" ++ h.month ++ "/" ++ h.day


