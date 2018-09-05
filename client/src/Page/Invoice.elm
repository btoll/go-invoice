module Page.Invoice exposing (Model, Msg, init, update, view)

import Data.Company exposing (Company)
import Data.Invoice exposing (Invoice, new)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Company
import Request.Invoice
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Time
import Util.Date
import Validate.Invoice
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal



-- MODEL


type alias Model =
    { errors : List ( Validate.Invoice.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe Invoice
    , disabled : Bool

    , invoices : List Invoice
    , companies : List Company
    , selectedCompanyID : Int

    , startDate : Maybe Date
    , endDate : Maybe Date
    , startDatePicker : DatePicker.DatePicker
    , endDatePicker : DatePicker.DatePicker

    , showModal : ( Bool, Maybe Modal.Modal )
    }


type Action = None | Adding | Editing | Selected



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
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True

    , invoices = []
    , companies = []
    , selectedCompanyID = -1

    , startDate = Nothing
    , endDate = Nothing
    , startDatePicker = startDatePicker
    , endDatePicker = endDatePicker

    , showModal = ( False, Nothing )
    } ! [ Cmd.map DatePickerStart startDatePickerFx
        , Cmd.map DatePickerEnd endDatePickerFx
        , Request.Company.list url |> Http.send FetchedCompany
        ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | CompanySelected String
    | DatePickerEnd DatePicker.Msg
    | DatePickerStart DatePicker.Msg
    | Delete Invoice
    | Deleted ( Result Http.Error Invoice )
    | Edit Invoice
    | Export Invoice
    | Exported ( Result Http.Error Invoice )
    | FetchedCompany ( Result Http.Error ( List Company ) )
    | FetchedInvoice ( Result Http.Error ( List Invoice ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error Invoice )
    | PrintPreview Invoice
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
                action = Selected
                , editing = Nothing
                , startDate = Nothing
                , endDate = Nothing
            } ! []

        CompanySelected company_id ->
            let
                id = company_id |> Form.toInt
            in
            { model |
                selectedCompanyID = id
                , action = if (==) id -1 then None else Selected
            } !
                [ company_id
                    |> Request.Invoice.get url
                    |> Http.send FetchedInvoice
                ]

        DatePickerEnd subMsg ->
            let
                ( newDatePicker, datePickerFx, dateEvent ) =
                    model.endDatePicker
                    |> DatePicker.update (endSettings model.startDate) subMsg

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
                    model.startDatePicker
                        |> DatePicker.update (startSettings model.startDate) subMsg

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
            { model |
                editing = invoice |> Just
                , showModal = ( True, Nothing |> Modal.Delete |> Just )
            } ! []

        Deleted ( Ok deletedInvoice ) ->
            { model |
                invoices = model.invoices |> List.filter ( \m -> deletedInvoice.id /= m.id )
                , action = None
                , editing = Nothing
                , startDate = Nothing
                , endDate = Nothing
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

        Export invoice ->
            model !
            [
                invoice.id |> toString
                    |> Request.Invoice.export url
                        |> Http.toTask
                        |> Task.attempt Exported
            ]

        Exported ( Ok invoices ) ->
            model ! []

        Exported ( Err err ) ->
            model ! []

        FetchedCompany ( Ok companies ) ->
            { model |
                companies = companies
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedCompany ( Err err ) ->
            { model |
                companies = []
                , tableState = Table.initialSort "ID"
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

        ModalMsg subMsg ->
            let
                pattern =
                    model.showModal
                        |> Tuple.second
                        |> Maybe.withDefault ( Modal.Delete Nothing )

                ( showModal, editing, cmd ) =
                    case ( subMsg |> Modal.update, pattern ) of
                        -- Delete
                        ( True, Modal.Delete Nothing ) ->
                            ( False
                            , Nothing
                            , Maybe.withDefault new model.editing
                                |> Request.Invoice.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
                            )

                        -- PrintPreview, Close
                        ( False, Modal.PrintPreview ( Just invoice ) ) ->
                            ( False
                            , Nothing
                            , Cmd.none
                            )

                        -- PrintPreview, Print
                        ( True, Modal.PrintPreview ( Just invoice ) ) ->
                            ( False
                            , Nothing
                            , Maybe.withDefault new model.editing
                                |> .id |> toString
                                |> Request.Invoice.export url
                                    |> Http.toTask
                                    |> Task.attempt Exported
                            )

                        ( _, _ ) ->
                            ( False
                            , Nothing
                            , Cmd.none
                            )
            in
            { model |
                showModal = ( showModal, Nothing )
            } ! [ cmd ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just invoice ->
                            Validate.Invoice.errors invoice

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( Selected, Cmd.none )

                        Just invoice ->
                            ( Selected
                            , Request.Invoice.post url invoice
                                |> Http.toTask
                                |> Task.attempt Posted
                            )
                    else
                        ( Adding, Cmd.none )
            in
                { model |
                    action = action
                    , startDate = Nothing
                    , endDate = Nothing
                    , errors = errors
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

        PrintPreview invoice ->
            { model |
                editing = invoice |> Just
                , showModal = ( True, invoice |> Just |> Modal.PrintPreview |> Just )
            } ! []

        Put ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just invoice ->
                            Validate.Invoice.errors invoice

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( Selected
                            , Cmd.none
                            )

                        Just invoice ->
                            ( Selected
                            , Request.Invoice.put url invoice
                                |> Http.toTask
                                |> Task.attempt Putted
                            )
                    else
                        ( Adding, Cmd.none )
            in
                { model |
                    action = action
                    , errors = errors
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
        ( (++)
            [ h1 [] [ text "Invoices" ]
            , Errors.view model.errors
            ]
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

        options : List Company -> List ( Html Msg )
        options companies =
            companies
                |> List.map ( \m -> ( m.id |> toString, m.name ++ " | " ++ m.city ++ ", " ++ m.state ) )
                |> (::) ( "-1", "-- Select an company --" )
                |> List.map ( model.selectedCompanyID |> toString |> Form.option )

        selectCompany =
            Form.select "Company"
                [ id "companySelection"
                , onInput CompanySelected
                ]
                ( model.companies |> options )
    in
    case model.action of
        None ->
            [ selectCompany
            ]
--            [ button [ onClick Add ] [ text "Add Invoice" ]
--            , Table.view config model.tableState model.invoices
--            , model.showModal
--                |> Modal.view model.editing
--                |> Html.map ModalMsg
--            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( formFields model editable )
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( formFields model editable )
            ]

        Selected ->
            [ selectCompany
            , button [ onClick Add ] [ text "Add Entry" ]
            , Table.view config model.tableState model.invoices
            , model.showModal
                |> Modal.view Nothing
                |> Html.map ModalMsg
            ]

formFields : Model -> Invoice -> List ( Html Msg )
formFields model invoice =
    [ Form.text "Title"
        [ value invoice.title
        , onInput ( SetFormValue ( \v -> { invoice | title = v } ) )
        , autofocus True
        ]
        []
    , div [] [
        label [] [ text "Date From" ]
        , model.startDatePicker
            |> DatePicker.view model.startDate ( startSettings model.startDate )
            |> Html.map DatePickerStart
    ]
    , div [] [
        label [] [ text "Date To" ]
        , model.endDatePicker
            |> DatePicker.view model.endDate ( endSettings model.endDate )
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
    , Form.float "Rate"
        [ value ( toString invoice.rate )
        , onInput ( SetFormValue ( \v -> { invoice | rate = Form.toFloat v } ) )
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
        , Table.floatColumn "Rate" .rate
        , Table.floatColumn "Total Hours" .totalHours
        , customColumn "" ( viewButton Edit "Edit" )
        , customColumn "" ( viewButton Delete "Delete" )
        , customColumn "" ( viewButton PrintPreview "Print Preview" )
        , customColumn "" ( viewButton Export "Export as HTML" )
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
viewButton msg name invoice =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| invoice ] [ text name ]
        ]


