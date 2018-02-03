module Util.Date exposing (now, parse, rfc3339, simple, unsafeFromString)

import Date exposing (Date)
import Dict exposing (Dict)
import Task exposing (Task)



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


now : ( Date -> msg ) -> Cmd msg
now msg =
    Date.now
        |> Task.perform msg


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


-- http://package.elm-lang.org/packages/rluiten/elm-date-extra/latest
-- https://github.com/rluiten/elm-date-extra/blob/9.2.3/src/Date/Extra/Utils.elm
unsafeFromString : String -> Date
unsafeFromString stringDate =
    case Date.fromString stringDate of
        Err err ->
            Debug.crash "unsafeFromString"

        Ok date ->
            date


