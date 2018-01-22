module Util.Form exposing (checkboxRow, datePickerRow, disabledTextRow, hiddenTextRow, passwordRow, selectRow, floatRow, submitRow, textAreaRow, textRow)

import Date exposing (Date)
import DateTimePicker
import DateTimePicker.Config exposing (Config, DatePickerConfig, TimePickerConfig, defaultDateTimePickerConfig)
import Dict exposing (Dict)
import Html exposing (Html, div, input, label, option, select, text, textarea)
import Html.Attributes exposing (checked, class, disabled, for, hidden, id, selected, step, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)



checkboxRow : String -> Bool -> ( String -> msg ) -> Html msg
checkboxRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ checked val, disabled False, prepareId name |> id, type_ "checkbox" ] []
    ]


datePickerRow : String
    -> String
    -> { r | date : Dict String Date, datePickerState : Dict String DateTimePicker.State }
    -> Config ( DatePickerConfig { } ) msg
    -> Html msg
datePickerRow name which { date, datePickerState } datePickerConfig =
    div []
        [ label [] [ text name ]
        , DateTimePicker.datePickerWithConfig
            datePickerConfig
            []
            ( datePickerState
                |> Dict.get which
                |> Maybe.withDefault DateTimePicker.initialState
            )
            ( date
                |> Dict.get which
            )
        ]


disabledTextRow : String -> String -> ( String -> msg ) -> Html msg
disabledTextRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled True, prepareId name |> id, onInput fn, type_ "text", value val ] []
    ]


passwordRow : String -> String -> ( String -> msg ) -> Html msg
passwordRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled False, prepareId name |> id, onInput fn, type_ "password", value val ] []
    ]


-- Remove any spaces in name (`id` attr doesn't allow for spaces).
prepareId : String -> String
prepareId name =
    name
        |> String.words
        |> String.concat


-- TODO: Break the `select` creation into its own function for use across pages
-- that don't need it to be wrapped in a `div`.
selectRow : String -> String -> List String -> ( String -> msg ) -> Html msg
selectRow name selectedOption list fn =
    let
        opt s =
            option [ selected ( (==) s selectedOption ), value s ] [ text s ]
    in
        div [] [
            label [] [ text name ]
            , list
                |> (::) "-- Select an option --"
                |> List.map opt
                |> select [ onInput fn ]
        ]


floatRow : String -> String -> ( String -> msg ) -> Html msg
floatRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ prepareId name |> id, onInput fn, step "0.01", type_ "number", value val ] []
    ]


hiddenTextRow : String -> String -> Html msg
hiddenTextRow name val =
    div [ hidden True ] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled False, prepareId name |> id, type_ "text", value val ] []
    ]


submitRow : Bool -> msg -> Html msg
submitRow isDisabled toMsg =
    div [] [
        input [ disabled isDisabled, type_ "submit" ] []
        , input [ onClick toMsg, type_ "button", value "Cancel" ] []
    ]


textAreaRow : String -> String -> ( String -> msg ) -> Html msg
textAreaRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , textarea [ prepareId name |> id, onInput fn, prepareId name |> Html.Attributes.name ] [ text val ]
--        , input [ disabled False, prepareId name |> id, onInput fn, type_ "text", value val ] []
    ]


textRow : String -> String -> ( String -> msg ) -> Html msg
textRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled False, prepareId name |> id, onInput fn, type_ "text", value val ] []
    ]


