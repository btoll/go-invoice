module Views.Modal exposing (Modal(..), Msg, update, view)

import Data.Invoice exposing(Invoice)
import Html exposing (Html, Attribute, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Modal.Delete as Delete
import Modal.Preview as Preview



maskStyle : Attribute msg
maskStyle =
  style
    [ ("background-color", "rgba(0,0,0,0.3)")
    , ("position", "fixed")
    , ("top", "0")
    , ("left", "0")
    , ("width", "100%")
    , ("height", "100%")
    ]


modalStyle : Attribute msg
modalStyle =
  style
    [ ("background-color", "rgba(255,255,255,1.0)")
    , ("position", "absolute")
    , ("top", "50%")
    , ("left", "50%")
    , ("height", "auto")
    , ("max-height", "80%")
    , ("width", "700px")
    , ("max-width", "95%")
    , ("padding", "10px")
    , ("border-radius", "3px")
    , ("box-shadow", "1px 1px 5px rgba(0,0,0,0.5)")
    , ("transform", "translate(-50%, -50%)")
    ]



type Modal
    = Delete Invoice
    | Preview Invoice
--type Modal a
--    = Delete a
--    | Preview a



type Msg
    = DeleteMsg Delete.Msg
    | PreviewMsg Preview.Msg



update : Msg -> ( Invoice -> Cmd msg ) -> ( Bool, Cmd msg )
update msg closure =
    case msg of
        DeleteMsg subMsg ->
            closure
                |> Delete.update subMsg

        PreviewMsg subMsg ->
            closure
                |> Preview.update subMsg


view : ( Bool, Maybe Modal ) -> Html Msg
view modal =
    case modal of
        ( True, Just modal ) ->
            let
                view : Html Msg
                view =
                    case modal of
                        Delete invoice ->
                            invoice
                                |> Delete.view
                                |> Html.map DeleteMsg

                        Preview invoice ->
                            invoice
                                |> Preview.view
                                |> Html.map PreviewMsg
            in
            div [ maskStyle ] [
                div [ modalStyle ] [ view ]
                ]

        ( _, _ ) ->
            div [] []


