module Modal.PrintPreview exposing (Msg, update, view)

import Data.Entry exposing (Entry)
import Data.PrintPreview exposing (PrintPreview)
import Data.Invoice exposing (Invoice)
import Html exposing (Html, a, button, div, h1, h4, li, p, pre, span, text, ul)
import Html.Attributes exposing (class, hidden, href, id, style, target)
import Html.Events exposing (onClick)



type Msg
    = Close
    | Export



entryItemHeader : Entry -> Html Msg
entryItemHeader entry =
    div [ "entryItemHeader" |> class ] [
        span [] [ entry.date |> text ]
        , span [] [ ( " hours" |> (++) ( entry.hours |> toString ) ) |> text ]
        , (
            if entry.reference |> List.isEmpty
            then ul [ True |> hidden ] []
            else
                entry.reference
                    |> List.map (
                        \ref ->
                            li [] [
                                a [ ref |> href, "_blank" |> target ] [ ref |> text ]
                                ]
                        )
                    |> ul []
        )
    ]


entryItem : Entry -> Html Msg
entryItem entry =
    li [] [
        entry |> entryItemHeader
        , div [] [
            p [ "bold" |> class ] [ entry.title |> text ]
            , div [] [
                pre [] [ entry.notes |> text ]
            ]
        ]
    ]


printPreview : PrintPreview -> Html Msg
printPreview previewData =
    div [] [
        div [ "header" |> id ] [
            div [ "invoiceInfo" |> id, "box" |> class ] [
                p [] [ span [] [ "Invoice Number: " |> text ], "" |> text ]
                , p [] [ span [] [ "Invoice Date: " |> text ], "" |> text ]
                , p [] [ span [] [ "Invoice Hours: " |> text ], ( previewData.invoice.totalHours |> toString ) |> text ]
                , p [] [ span [] [ "Invoice Amount: $" |> text ]
                    , (
                        previewData.invoice.rate |> (*) previewData.invoice.totalHours
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
                , p [] [ previewData.company.name |> text ]
                , p [] [ previewData.company.contact |> text ]
                , p [] [ previewData.company.street1 |> text ]
                , if "" |> (==) previewData.company.street2
                  then p [ True |> hidden ] []
                  else p [] [ previewData.company.street2 |> text ]
                , p [] [
                    (
                        ( ", " |> (++) previewData.company.city )
                        ++ (
                            " " |> (++) previewData.company.state
                            )
                        ++ previewData.company.zip
                    ) |> text ]
            ]
        ]
        , div [ "entries" |> id ] [
            p [ "period" |> id ] [
                span ["bold" |> class ] [ "Period - " |> text ]
                , span [] [ previewData.invoice.dateFrom |> text ]
                , span [] [ " // " |> text]
                , span [] [ previewData.invoice.dateTo |> text ]
            ]
            , h4 [] [ "Work Description" |> text ]
            , ul [ "entryItems" |> class ]
            ( previewData.invoice.entries |> List.map entryItem )
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



view : PrintPreview -> Html Msg
view previewData =
    let
        actions =
            div [ "printPreviewActions" |> id ] [
                button [ onClick Export ] [ text "Export as HTML" ]
                , button [ onClick Close ] [ text "Close" ]
            ]
    in
    div [ "printPreview" |> id ] [
        actions
        , previewData |> printPreview
        , actions
    ]


