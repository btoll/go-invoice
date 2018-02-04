module Page.Invoice exposing (Model, Msg, init, update, view)

import Data.Invoice exposing (Invoice, new)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Invoice
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Time
import Util.Date
import Views.Form as Form



-- MODEL


type alias Model =
    { tableState : Table.State
    , action : Action
    , editing : Maybe Invoice
    , disabled : Bool
    , invoices : List Invoice

    , startDate : Maybe Date
    , endDate : Maybe Date
    , startDatePicker : DatePicker.DatePicker
    , endDatePicker : DatePicker.DatePicker
    }


type Action = None | Adding | Editing


commonSettings : DatePicker.Settings
commonSettings =
    defaultSettings


startSettings : Maybe Date -> DatePicker.Settings
startSettings endDate =
    let
        isDisabled =
            case endDate of
                Nothing ->
                    commonSettings.isDisabled

                Just endDate ->
                    \d ->
                        Date.toTime d
                            > Date.toTime endDate
                            || (commonSettings.isDisabled d)
    in
        { commonSettings
            | placeholder = ""
            , isDisabled = isDisabled
        }


endSettings : Maybe Date -> DatePicker.Settings
endSettings startDate =
    let
        isDisabled =
            case startDate of
                Nothing ->
                    commonSettings.isDisabled

                Just startDate ->
                    \d ->
                        Date.toTime d
                            < Date.toTime startDate
                            || (commonSettings.isDisabled d)
    in
        { commonSettings
            | placeholder = ""
            , isDisabled = isDisabled
        }


init : String -> ( Model, Cmd Msg )
init url =
    let
        ( startDatePicker, startDatePickerFx ) =
            DatePicker.init

        ( endDatePicker, endDatePickerFx ) =
            DatePicker.init
    in
        { tableState = Table.initialSort "ID"
        , action = None
        , editing = Nothing
        , disabled = True
        , invoices = []

        , startDate = Nothing
        , endDate = Nothing
        , startDatePicker = startDatePicker
        , endDatePicker = endDatePicker
        } ! [ Cmd.map DatePickerStart startDatePickerFx
            , Cmd.map DatePickerEnd endDatePickerFx
            , Request.Invoice.get url |> Http.send FetchedInvoice
            ]


-- UPDATE


type Msg
    = Add
    | AddEntry Invoice
    | Cancel
    | DatePickerEnd DatePicker.Msg
    | DatePickerStart DatePicker.Msg
    | Delete Invoice
    | Deleted ( Result Http.Error Invoice )
    | Edit Invoice
    | FetchedInvoice ( Result Http.Error ( List Invoice ) )
    | Post
    | Posted ( Result Http.Error Invoice )
    | Print Invoice
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

        AddEntry invoice ->
            model ! []

        Cancel ->
            { model |
                action = None
                , editing = Nothing
                , startDate = Nothing
                , endDate = Nothing
            } ! []

        DatePickerEnd subMsg ->
            let
                ( newDatePicker, datePickerFx, dateEvent ) =
                    DatePicker.update (endSettings model.startDate) subMsg model.endDatePicker

                ( newDate, newInvoice ) =
                    let
                        invoice = Maybe.withDefault new model.editing
                    in
                    case dateEvent of
                        Changed newDate ->
                            let
                                dateString =
                                    case dateEvent of
                                        Changed date ->
                                            case date of
                                                Nothing ->
                                                    ""

                                                Just d ->
                                                    d |> Util.Date.simple

                                        _ ->
                                            invoice.dateTo
                            in
                            ( newDate , { invoice | dateTo = dateString } )

                        _ ->
                            ( model.endDate, { invoice | dateTo = invoice.dateTo } )
            in
            { model
                | endDate = newDate
                , endDatePicker = newDatePicker
                , editing = Just newInvoice
            } ! [ Cmd.map DatePickerEnd datePickerFx ]

        DatePickerStart subMsg ->
            let
                ( newDatePicker, datePickerFx, dateEvent ) =
                    DatePicker.update (startSettings model.startDate) subMsg model.startDatePicker

                ( newDate, newInvoice ) =
                    let
                        invoice = Maybe.withDefault new model.editing
                    in
                    case dateEvent of
                        Changed newDate ->
                            let
                                dateString =
                                    case dateEvent of
                                        Changed date ->
                                            case date of
                                                Nothing ->
                                                    ""

                                                Just d ->
                                                    d |> Util.Date.simple

                                        _ ->
                                            invoice.dateFrom
                            in
                            ( newDate , { invoice | dateFrom = dateString } )

                        _ ->
                            ( model.endDate, { invoice | dateFrom = invoice.dateFrom } )
            in
            { model
                | startDate = newDate
                , startDatePicker = newDatePicker
                , editing = Just newInvoice
            } ! [ Cmd.map DatePickerStart datePickerFx ]

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
                , startDate = Nothing
                , endDate = Nothing
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
                , startDate = invoice.dateFrom |> Util.Date.unsafeFromString |> Just
                , endDate = invoice.dateTo |> Util.Date.unsafeFromString |> Just
            } ! []

        FetchedInvoice ( Ok invoices ) ->
            { model |
                invoices = invoices
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedInvoice ( Err err ) ->
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
                , startDate = Nothing
                , endDate = Nothing
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

        Print invoice ->
            model ! []

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
                            new

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


view : Model -> Html Msg
view model =
    section []
        ( (::)
            ( h1 [] [ text "Invoices" ] )
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView model =
    let
        editable : Invoice
        editable = case model.editing of
            Nothing ->
                new

            Just invoice ->
                invoice
    in
        case model.action of
            None ->
                [ button [ onClick Add ] [ text "Add Invoice" ]
                , Table.view config model.tableState model.invoices
                ]

            Adding ->
                [ form [ onSubmit Post ]
                    ( formFields model editable )
                ]

            Editing ->
                [ form [ onSubmit Put ]
                    ( formFields model editable )
                ]


formFields : Model -> Invoice -> List ( Html Msg )
formFields model invoice =
    [ Form.text"Title"
        [ value invoice.title
        , onInput ( SetFormValue ( \v -> { invoice | title = v } ) )
        , autofocus True
        ]
        []
    , div [] [
        label [] [ text "Date From" ]
        , DatePicker.view model.startDate ( startSettings model.startDate ) model.startDatePicker
            |> Html.map DatePickerStart
    ]
    , div [] [
        label [] [ text "Date To" ]
        , DatePicker.view model.endDate ( endSettings model.endDate ) model.endDatePicker
            |> Html.map DatePickerEnd
    ]
    , Form.text "URL"
        [ value invoice.url
        , onInput ( SetFormValue ( \v -> { invoice | url = v } ) )
        ]
        []
    , Form.textarea "Comment"
        [ value invoice.comment
        , onInput ( SetFormValue ( \v -> { invoice | comment = v } ) )
        ]
        []
    , Form.float "Total Hours"
        [ value ( toString invoice.totalHours )
        , onInput ( SetFormValue ( \v -> { invoice | totalHours = Form.toFloat v } ) )
        ]
        []
    , Form.submit model.disabled Cancel
    ]



-- TABLE CONFIGURATION


config : Table.Config Invoice Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
    { toId = .dateFrom
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Title" .title
        , Table.stringColumn "Date From" .dateFrom
        , Table.stringColumn "Date To" .dateTo
        , Table.stringColumn "URL" .url
        , Table.stringColumn "Comment" .comment
        , Table.floatColumn "Total Hours" .totalHours
        , customColumn "" ( viewButton AddEntry "Add Entry" )
        , customColumn "" ( viewButton Edit "Edit" )
        , customColumn "" ( viewButton Delete "Delete" )
        , customColumn "" ( viewButton Print "Print" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Invoice -> List ( Attribute Msg )
toRowAttrs sport =
    [ style [ ( "background", "white" ) ]
    ]


customColumn : String -> ( Invoice -> Table.HtmlDetails Msg ) -> Table.Column Invoice Msg
customColumn name viewElement =
    Table.veryCustomColumn
        { name = name
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( Invoice -> msg ) -> String -> Invoice -> Table.HtmlDetails msg
viewButton msg name sport =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| sport ] [ text name ]
        ]


