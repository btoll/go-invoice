module Page.Invoice exposing (Model, Msg, init, update, view)

import Css
import Data.Invoice exposing (Invoice)
import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format
import DateParser
import DateTimePicker
import DateTimePicker.Config exposing (Config, DatePickerConfig, defaultDatePickerConfig)
import DateTimePicker.Css
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Invoice
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Form as Form



-- MODEL


type alias Model =
    -- NOTE: Order matters here (see `init`)!
    { tableState : Table.State
    , action : Action
    , editing : Maybe Invoice
    , disabled : Bool
    , date : Dict String Date -- The key is actually a DemoPicker
    , datePickerState : Dict String DateTimePicker.State -- The key is actually a DemoPicker
    , invoices : List Invoice
    }


type DemoPicker
    = DateTimePicker


type Action = None | Adding | Editing


init : String -> ( Model, Cmd Msg )
init url =
    ( Model ( Table.initialSort "ID" ) None Nothing True Dict.empty Dict.empty [] ) !
        [ Request.Invoice.get url |> Http.send Getted
        , DateTimePicker.initialCmd DatePickerChanged DateTimePicker.initialState
        ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePickerChanged DateTimePicker.State ( Maybe Date )
    | Delete Invoice
    | Deleted ( Result Http.Error Invoice )
    | Edit Invoice
    | Getted ( Result Http.Error ( List Invoice ) )
    | Post
    | Posted ( Result Http.Error Invoice )
    | Put
    | Putted ( Result Http.Error Int )
    | SetFormValue ( String -> Invoice ) String
    | SetTableState Table.State
    | Submit


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    case msg of
        Add ->
            { model |
                action = Adding
                , editing = Nothing
            } ! []

        Cancel ->
            { model |
                action = None
                , editing = Nothing
            } ! []

        DatePickerChanged state value ->
            let
                editable : Invoice
                editable = case model.editing of
                    Nothing ->
                        Invoice -1 "" "" "" "" 0.00

                    Just invoice ->
                        invoice
            in
                { model
                    | date =
                        case value of
                            Nothing ->
                                Dict.remove ( toString DateTimePicker ) model.date

                            Just date ->
                                Dict.insert ( toString DateTimePicker ) date model.date
                    , datePickerState = Dict.insert ( toString DateTimePicker ) state model.datePickerState
                    , editing = Just ( { editable | date = value |> toString } )
                } ! []

        Delete invoice ->
            let
                subCmd =
                    Request.Invoice.delete url invoice
                        |> Http.toTask
                        |> Task.attempt Deleted
            in
                { model |
                    action = None
                    , editing = Nothing
                } ! [ subCmd ]

        Deleted ( Ok deletedInvoice ) ->
            { model |
                invoices = model.invoices |> List.filter ( \m -> deletedInvoice.id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            model ! []

        Edit invoice ->
            { model |
                action = Editing
                , editing = Just invoice
            } ! []

        Getted ( Ok invoices ) ->
            { model |
                invoices = invoices
                , tableState = Table.initialSort "ID"
            } ! []

        Getted ( Err err ) ->
            { model |
                invoices = []
                , tableState = Table.initialSort "ID"
            } ! []

        Post ->
            let
                subCmd = case model.editing of
                    Nothing ->
                        Cmd.none

                    Just invoice ->
                        Request.Invoice.post url invoice
                            |> Http.toTask
                            |> Task.attempt Posted
            in
                { model |
                    action = None
                } ! [ subCmd ]

        Posted ( Ok invoice ) ->
            let
                invoices =
                    case model.editing of
                        Nothing ->
                            model.invoices

                        Just newInvoice ->
                            model.invoices
                                |> (::) { newInvoice | id = invoice.id }
            in
                { model |
                    invoices = invoices
                    , editing = Nothing
                } ! []

        Posted ( Err err ) ->
            { model |
                editing = Nothing
            } ! []

        Put ->
            let
                subCmd = case model.editing of
                    Nothing ->
                        Cmd.none

                    Just invoice ->
                        Request.Invoice.put url invoice
                            |> Http.toTask
                            |> Task.attempt Putted
            in
                { model |
                    action = None
                } ! [ subCmd ]

        Putted ( Ok id ) ->
            let
                invoices =
                    case model.editing of
                        Nothing ->
                            model.invoices

                        Just newInvoice ->
                            model.invoices
                                |> (::) { newInvoice | id = id }
                newInvoice =
                    case model.editing of
                        -- TODO
                        Nothing ->
                            Invoice -1 "" "" "" "" 0.00

                        Just invoice ->
                            invoice
            in
                { model |
                    invoices =
                        model.invoices
                            |> List.filter ( \m -> newInvoice.id /= m.id )
                            |> (::) newInvoice
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = Just ( setFormValue s )
                , disabled = False
            } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []

        Submit ->
            { model |
                action = None
                , disabled = True
            } ! []




-- VIEW


datePickerConfig : Config ( DatePickerConfig { } ) Msg
datePickerConfig =
    defaultDatePickerConfig DatePickerChanged


view : Model -> Html Msg
view model =
    section []
        ( (::)
            ( h1 [] [ text "Invoices" ] )
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView ( { action, disabled, editing, tableState, invoices } as model ) =
    let
        editable : Invoice
        editable = case editing of
            Nothing ->
                Invoice -1 "" "" "" "" 0.00

            Just invoice ->
                invoice

        { css } =
            Css.compile [ DateTimePicker.Css.css ]
    in
        case action of
            None ->
                [ button [ onClick Add ] [ text "Add Invoice" ]
                , Table.view config tableState invoices
                ]

            Adding ->
                [ form [ onSubmit Post ] [
                    node "style" [] [ text css ]
                    , Form.datePickerRow "Date" "DateTimePicker" model datePickerConfig
                    , Form.textRow "Title" editable.title ( SetFormValue (\v -> { editable | title = v }) )
                    , Form.textRow "URL" editable.url ( SetFormValue (\v -> { editable | url = v }) )
                    , Form.textAreaRow "Comment" editable.comment ( SetFormValue (\v -> { editable | comment = v }) )
                    , Form.floatRow "Hours" ( toString editable.hours ) ( SetFormValue (\v -> { editable | hours = ( Result.withDefault 0.00 ( String.toFloat v ) ) } ) )
                    , Form.submitRow disabled Cancel
                    ]
                ]

            Editing ->
                [ form [ onSubmit Put ] [
                    node "style" [] [ text css ]
                    , Form.datePickerRow "Date" "DateTimePicker" model datePickerConfig
                    , Form.textRow "Title" editable.title ( SetFormValue (\v -> { editable | title = v }) )
                    , Form.textRow "URL" editable.url ( SetFormValue (\v -> { editable | url = v }) )
                    , Form.textAreaRow "Comment" editable.comment ( SetFormValue (\v -> { editable | comment = v }) )
                    , Form.floatRow "Hours" ( toString editable.hours ) ( SetFormValue (\v -> { editable | hours = ( Result.withDefault 0.00 ( String.toFloat v ) ) } ) )
                    , Form.submitRow disabled Cancel
                    ]
                ]


-- TABLE CONFIGURATION


config : Table.Config Invoice Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
    { toId = .date
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Date" .date
        , Table.stringColumn "Title" .title
        , Table.stringColumn "URL" .url
        , Table.stringColumn "Comment" .comment
        , Table.floatColumn "Hours" .hours
        , Form.customColumn ( Form.tableButton Edit )
        , Form.customColumn ( Form.tableButton Delete )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = Form.toRowAttrs }
    }


