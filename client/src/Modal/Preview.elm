module Modal.Preview exposing (Msg, update, view)

import Data.Entry exposing (Entry)
import Data.Invoice exposing (Invoice)
import Html exposing (Html, button, div, h1, li, p, text, ul)
import Html.Events exposing (onClick)



type Msg
    = Close
    | Print



entryItem : Entry -> Html Msg
entryItem entry =
    li [] [
        p [] [ text entry.title ]
        , p [] [ text ( (++) "Date: " entry.date ) ]
        , p [] [ text ( (++) "URL: " entry.url ) ]
        , p [] [ text ( (++) "Comment: " entry.comment ) ]
        , p [] [ text ( (++) "Hours: "( entry.hours |> toString ) ) ]
    ]


invoiceHeader : Invoice -> Html Msg
invoiceHeader invoice =
    div [] [
        h1 [] [ text invoice.title ]
        , p [] [ text ( (++) "From: " invoice.dateFrom ) ]
        , p [] [ text ( (++) "To: " invoice.dateTo ) ]
        , p [] [ text ( (++) "URL: " invoice.url ) ]
        , p [] [ text ( (++) "Comment: " invoice.comment ) ]
        , p [] [ text ( (++) "Rate: " ( invoice.rate |> toString ) ) ]
        , p [] [ text ( (++) "Total Hours: "( invoice.totalHours |> toString ) ) ]
    ]



update : Msg -> Bool
update msg =
    case msg of
        Close ->
            True

        Print ->
            True



view : Invoice -> Html Msg
view invoice =
    div [] [
        invoice |> invoiceHeader
        , div [] [
            p [] [ "Entries: " |> text  ]
            , ul []
                ( invoice.entries |> List.map entryItem )
        ]
        , button [ onClick Print ] [ text "Print" ]
        , button [ onClick Close ] [ text "Close" ]
        ]


