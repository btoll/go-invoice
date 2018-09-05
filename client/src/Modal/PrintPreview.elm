module Modal.PrintPreview exposing (Msg, update, view)

import Data.Entry exposing (Entry)
import Data.Invoice exposing (Invoice)
import Html exposing (Html, button, div, h1, h4, li, p, span, table, tr, td, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)



type Msg
    = Close
    | Export


rowLine : Entry -> String
rowLine entry =
    ( (++) entry.date ", " )
    ++ (
        " hours"
            |> (++) ( entry.hours |> toString )
        )
    ++ (
        if  (/=) entry.url ""
        then (++) ", " entry.url
        else ""
    )

entryItem : Entry -> Html Msg
entryItem entry =
    li [] [
        span [] [ entry |> rowLine |> text ]
        , table [] [
            tr [] [
                td [ "bold" |> class ] [ entry.title |> text ]
            ]
            , tr [] [
                td [] [ entry.comment |> text ]
            ]
        ]
    ]


printPreview : Invoice -> Html Msg
printPreview invoice =
    div [] [
        div [ "header" |> id ] [
            div [ "invoiceInfo" |> id, "box" |> class ] [
                p [] [ span [] [ "Invoice Number: " |> text ], "" |> text ]
                , p [] [ span [] [ "Invoice Date: " |> text ], "" |> text ]
                , p [] [ span [] [ "Invoice Hours: " |> text ], ( invoice.totalHours |> toString ) |> text ]
                , p [] [ span [] [ "Invoice Amount: $" |> text ]
                    , (
                        invoice.rate |> (*) invoice.totalHours
                            |> toString
                        ) |> text
                    ]
            ]
            , div [ "from" |> id, "box" |> class ] [
                h4 [] [ "From:" |> text ]
                , p [] [ "Benjamin Toll" |> text ]
                , p [] [ "113 Old Colony Road" |> text ]
                , p [] [ "Princeton, MA 01541" |> text ]
            ]
            , div [ "to" |> id, "box" |> class ] [
                h4 [] [ "Bill To:" |> text ]
                , p [] [ "Benjamin Toll" |> text ]
                , p [] [ "113 Old Colony Road" |> text ]
                , p [] [ "Princeton, MA 01541" |> text ]
            ]
        ]
        , div [ "entries" |> id ] [
            p [ "period" |> id ] [
                span ["bold" |> class ] [ "Period - " |> text ]
                , span [] [ invoice.dateFrom |> text ]
                , span [] [ " // " |> text]
                , span [] [ invoice.dateTo |> text ]
            ]
            , h4 [] [ "Work Description" |> text ]
            , ul []
            ( invoice.entries |> List.map entryItem )
        ]
        , div [ "footer" |> id ] [
            p [] [ "Please pay upon receipt." |> text ]
            , p [] [ "Thank you!" |> text ]
        ]
    ]



update : Msg -> Bool
update msg =
    case msg of
        Close ->
            False

        Export ->
            True



view : Invoice -> Html Msg
view invoice =
    div [ "printPreview" |> id ] [
        invoice |> printPreview
        , button [ onClick Export ] [ text "Export as HTML" ]
        , button [ onClick Close ] [ text "Close" ]
        ]


