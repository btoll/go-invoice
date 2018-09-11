module Views.Modal exposing (Modal(..), Msg, update, view)

import Data.Invoice exposing (Invoice, new)
import Data.PrintPreview
import Html exposing (Html, Attribute, button, div, text)
import Html.Attributes exposing (id, style)
import Html.Events exposing (onClick)
import Modal.Delete as Delete
import Modal.PrintPreview as PrintPreview



type Modal
    = Delete ( Maybe Data.PrintPreview.PrintPreview )
    | PrintPreview ( Maybe Data.PrintPreview.PrintPreview )



type Msg
    = DeleteMsg Delete.Msg
    | PrintPreviewMsg PrintPreview.Msg



update : Msg -> Bool
update msg =
    case msg of
        DeleteMsg subMsg ->
            Delete.update subMsg

        PrintPreviewMsg subMsg ->
            PrintPreview.update subMsg


view : Maybe Data.PrintPreview.PrintPreview -> ( Bool, Maybe Modal ) -> Html Msg
view printPreview modal =
    case modal of
        ( True, Just modal ) ->
            let
                view : Html Msg
                view =
                    case modal of
                        Delete _ ->
                            Delete.view
                                |> Html.map DeleteMsg

                        PrintPreview printPreview ->
                            Maybe.withDefault Data.PrintPreview.newPrintPreview printPreview
                                |> PrintPreview.view
                                |> Html.map PrintPreviewMsg
            in
            div [ "modal-mask" |> id ] [
                div [ "modal-content" |> id ] [ view ]
                ]

        ( _, _ ) ->
            div [] []


