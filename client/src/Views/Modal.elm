module Views.Modal exposing (Modal(..), Msg, update, view)

import Data.Invoice exposing (Invoice, new)
import Html exposing (Html, Attribute, button, div, text)
import Html.Attributes exposing (id, style)
import Html.Events exposing (onClick)
import Modal.Delete as Delete
import Modal.Preview as Preview



type Modal
    = Delete ( Maybe Invoice )
    | Preview ( Maybe Invoice )



type Msg
    = DeleteMsg Delete.Msg
    | PreviewMsg Preview.Msg



update : Msg -> Bool
update msg =
    case msg of
        DeleteMsg subMsg ->
            Delete.update subMsg

        PreviewMsg subMsg ->
            Preview.update subMsg


view : Maybe Invoice -> ( Bool, Maybe Modal ) -> Html Msg
view invoice modal =
    case modal of
        ( True, Just modal ) ->
            let
                view : Html Msg
                view =
                    case modal of
                        Delete _ ->
                            Delete.view
                                |> Html.map DeleteMsg

                        Preview invoice ->
                            Maybe.withDefault new invoice
                                |> Preview.view
                                |> Html.map PreviewMsg
            in
            div [ "modal-mask" |> id ] [
                div [ "modal-content" |> id ] [ view ]
                ]

        ( _, _ ) ->
            div [] []


