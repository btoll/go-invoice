module Modal.Preview exposing (Msg, update, view)

import Data.Invoice exposing (Invoice)
import Html exposing (Html, button, div, p, text)
import Html.Events exposing (onClick)



type Msg
    = Close
    | Print



update : Msg -> ( Invoice -> Cmd msg ) -> ( Bool, Cmd msg )
update msg fn =
    case msg of
        Close ->
            ( True, Cmd.none )

        Print ->
--            ( True, invoice |> fn )
            ( True, Cmd.none )



view : Invoice -> Html Msg
view invoice =
    div [] [
        p [] [ text invoice.title ]
        , p [] [ text invoice.dateFrom ]
        , p [] [ text invoice.dateTo ]
        , p [] [ text invoice.url ]
        , p [] [ text invoice.comment ]
        , p [] [ text ( invoice.rate |> toString ) ]
        , p [] [ text ( invoice.totalHours |> toString ) ]
        , button [ onClick Print ] [ text "Print" ]
        , button [ onClick Close ] [ text "Close" ]
        ]


