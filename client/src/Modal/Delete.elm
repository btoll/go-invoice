module Modal.Delete exposing (Msg, update, view)

import Data.Invoice exposing (Invoice)
import Html exposing (Html, button, div, p, text)
import Html.Events exposing (onClick)
import Http
import Request.Invoice
import Task



type Msg
    = Yes Invoice
    | No



update : Msg -> ( Invoice -> Cmd msg ) -> ( Bool, Cmd msg )
update msg fn =
    case msg of
        Yes invoice ->
            ( True, invoice |> fn )

        No ->
            ( False, Cmd.none )



view : Invoice -> Html Msg
view invoice =
    div [] [
        p [] [ text "Are you sure you wish to proceed?  This will also permanently delete all of the invoice's entries.  This is irreversible!" ]
        , button [ invoice |> Yes |> onClick ] [ text "Yes" ]
        , button [ onClick No ] [ text "No" ]
        ]


