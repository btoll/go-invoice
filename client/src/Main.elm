module Main exposing (..)

import Data.Invoice exposing (Invoice)
import Html exposing (Html, text)
import Http
import Navigation
import Page.Invoice as Invoice
import Page.NotFound as NotFound
import Ports exposing (fileContentRead, fileSelected)
import Route exposing (Route)
import Task
import Views.Page as Page exposing (ActivePage)


type alias Build =
    {
        url : String
    }


type alias Flags =
    {
        env : Maybe String
    }


type Page
    = Blank
    | NotFound
--    | Home Home.Model
    | Errored String
--    | Home Home.Model
    | Invoice Invoice.Model



-- MODEL


type alias Model =
    { build : Build
    , page : Page
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        url =
            if ( Maybe.withDefault "dev" flags.env ) == "production"
            then "https://www.benjamintoll.com"
            else "http://localhost:8080"
    in
        setRoute ( Route.fromLocation location )
            { build = { url = url }
            , page = initialPage
            }


initialPage : Page
initialPage =
    Blank



-- UPDATE


type Msg
    = SetRoute ( Maybe Route )
    | InvoiceLoaded ( Result Http.Error Invoice.Model )
    | InvoiceMsg Invoice.Msg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        m = (Debug.log "maybeRoute" maybeRoute)
    in
    case maybeRoute of
        Just Route.Invoice ->
            let
                ( subModel, subMsg ) =
                    Invoice.init model.build.url
            in
                { model |
                    page = Invoice subModel
                } ! [ Cmd.map InvoiceMsg subMsg ]
--            ( model, Invoice.init model.build.url |> Task.attempt InvoiceLoaded )

        Just Route.Home ->
            { model | page = Blank } ! []

        Nothing ->
            { model | page = Errored "404: Page not found." } ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate model.build.url subMsg subModel
            in
                -- Mapping the newCmd to SpecialistMsg causes the Elm runtime to call `update` again with the subsequent newCmd!
                { model | page = toModel newModel } ! [ Cmd.map toMsg newCmd ]
    in
        case ( msg, model.page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( InvoiceLoaded ( Ok subModel ), _ ) ->
                { model | page = Invoice subModel } ! []

            ( InvoiceLoaded ( Err err ), _ ) ->
                model ! []

            ( InvoiceMsg subMsg, Invoice subModel ) ->
                toPage Invoice InvoiceMsg Invoice.update subMsg subModel

            _ ->
                model ! []

-- VIEW


view : Model -> Html Msg
view model =
    let
        frame =
            Page.frame
    in
    case model.page of
        Blank ->
            -- This is for the very initial page load, while we are loading
            -- data via HTTP. We could also render a spinner here.
            text ""
                |> frame Page.Home

        Invoice subModel ->
            Invoice.view subModel
                |> frame Page.Invoice
                |> Html.map InvoiceMsg

        Errored err ->
            text err
                |> frame Page.Other

        NotFound ->
            NotFound.view
                |> frame Page.Other



-- MAIN --


main : Program Flags Model Msg
main =
    Navigation.programWithFlags ( Route.fromLocation >> SetRoute )
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


