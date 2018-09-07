module Page.Entry exposing (Model, Msg, init, update, view)

import Data.Entry exposing (Entry, new)
import Data.Invoice exposing (Invoice)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, autofocus, checked, class, disabled, for, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Entry
import Request.Invoice
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Time
import Util.Date
import Validate.Entry
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal



-- MODEL


type alias Model =
    { errors : List String
    , tableState : Table.State
    , action : Action
    , editing : Maybe Entry
    , disabled : Bool

    , entries : List Entry
    , invoices : List Invoice
    , selectedInvoiceID : Int

    , date : Maybe Date
    , datePicker : DatePicker.DatePicker

    , showModal : ( Bool, Maybe Modal.Modal )
    }


type Action = None | Adding | Editing | Selected


commonSettings : DatePicker.Settings
commonSettings =
    defaultSettings


settings : Maybe Date -> DatePicker.Settings
settings date =
    let
        isDisabled =
            case date of
                Nothing ->
                    commonSettings.isDisabled

                Just date ->
                    \d ->
                        Date.toTime d
                            > Date.toTime date
                            || (commonSettings.isDisabled d)
    in
        { commonSettings
            | placeholder = ""
            , isDisabled = isDisabled
        }


init : String -> ( Model, Cmd Msg )
init url =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init
    in
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True

    , entries = []
    , invoices = []
    , selectedInvoiceID = -1

    , date = Nothing
    , datePicker = datePicker
    , showModal = ( False, Nothing )
    } ! [ Cmd.map DatePicker datePickerFx
        , "1"
            |> Request.Invoice.get url
            |> Http.send FetchedInvoice
        ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete Entry
    | Deleted ( Result Http.Error Entry )
    | Edit Entry
    | FetchedEntry ( Result Http.Error ( List Entry ) )
    | FetchedInvoice ( Result Http.Error ( List Invoice ) )
    | InvoiceSelected String
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error Entry )
    | Put
    | Putted ( Result Http.Error Int )
    | SetFormValue ( String -> Entry ) String
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
                , date = Nothing
            } ! []

        DatePicker subMsg ->
            let
                ( newDatePicker, datePickerFx, dateEvent ) =
                    DatePicker.update ( settings model.date ) subMsg model.datePicker

                ( newDate, newEntry ) =
                    let
                        entry = Maybe.withDefault new model.editing
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
                                            entry.date
                            in
                            ( newDate , { entry | date = dateString } )

                        _ ->
                            ( model.date, { entry | date = entry.date } )
            in
            { model
                | date = newDate
                , datePicker = newDatePicker
                , editing = Just newEntry
            } ! [ Cmd.map DatePicker datePickerFx ]

        Delete entry ->
            { model |
                editing = entry |> Just
                , showModal = ( True, Nothing |> Modal.Delete |> Just )
            } ! []

        Deleted ( Ok deletedEntry ) ->
            { model |
                entries = model.entries |> List.filter ( \m -> deletedEntry.id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            model ! []

        Edit entry ->
            { model |
                action = Editing
                , editing = Just entry
                , date = entry.date |> Util.Date.unsafeFromString |> Just
            } ! []

        FetchedEntry ( Ok entries ) ->
            { model |
                entries = entries
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedEntry ( Err err ) ->
            { model |
                entries = []
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

        InvoiceSelected invoice_id ->
            let
                id = invoice_id |> Form.toInt
            in
            { model |
                selectedInvoiceID = id
                , action = if (==) id -1 then None else Selected
            } !
                [ invoice_id
                    |> Request.Entry.get url
                    |> Http.send FetchedEntry
                ]

        ModalMsg subMsg ->
            let
                ( showModal, editing, cmd ) =
                    case subMsg |> Modal.update of
                        False ->
                            ( False, Nothing, Cmd.none )

                        True ->
                            ( True
                            , Nothing
                            , Maybe.withDefault new model.editing
                                |> Request.Entry.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
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
                            Validate.Entry.errors invoice

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just entry ->
                            { entry | invoice_id = model.selectedInvoiceID }
                                |> Request.Entry.post url
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
                { model |
                    date = Nothing
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok entry ) ->
            let
                entries =
                    case model.editing of
                        Nothing ->
                            model.entries

                        Just newEntry ->
                            model.entries
                                |> (::) { newEntry | id = entry.id }
            in
            { model |
                action = Selected
                , entries = entries
                , editing = Nothing
            } ! []

        Posted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                errors = (::) e model.errors
            } ! []

        Put ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just invoice ->
                            Validate.Entry.errors invoice

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just entry ->
                            Request.Entry.put url entry
                                |> Http.toTask
                                |> Task.attempt Putted
                    else
                        Cmd.none
            in
                { model |
                    errors = errors
                } ! [ subCmd ]

        Putted ( Ok id ) ->
            let
                entries =
                    case model.editing of
                        Nothing ->
                            model.entries

                        Just newEntry ->
                            model.entries
                                |> (::) { newEntry | id = id }
                newEntry =
                    case model.editing of
                        -- TODO
                        Nothing ->
                            new

                        Just entry ->
                            entry
            in
            { model |
                action = Selected
                , entries =
                    model.entries
                        |> List.filter ( \m -> newEntry.id /= m.id )
                        |> (::) newEntry
                , editing = Nothing
            } ! []

        Putted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                errors = (::) e model.errors
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
            [ h1 [] [ text "Entries" ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView model =
    let
        editable : Entry
        editable = case model.editing of
            Nothing ->
                new

            Just entry ->
                entry

        options : List Invoice -> List ( Html Msg )
        options invoices =
            invoices
                |> List.map ( \m -> ( m.id |> toString, ( m.company_id |> toString ) ++ " | " ++ m.dateFrom ++ " <> " ++ m.dateTo ) )
                |> (::) ( "-1", "-- Select an invoice --" )
                |> List.map ( model.selectedInvoiceID |> toString |> Form.option )

        selectInvoice =
            Form.select "Invoice"
                [ "itemSelection" |> class
                , onInput InvoiceSelected
                ]
                ( model.invoices |> options )
    in
    case model.action of
        None ->
            [ selectInvoice
            ]

        Adding ->
            [ selectInvoice
            , form [ onSubmit Post ]
                ( formFields model editable )
            ]

        Editing ->
            [ selectInvoice
            , form [ onSubmit Put ]
                ( formFields model editable )
            ]

        Selected ->
            [ selectInvoice
            , button [ onClick Add ] [ text "Add Entry" ]
            , Table.view config model.tableState model.entries
            , model.showModal
                |> Modal.view Nothing
                |> Html.map ModalMsg
            ]


formFields : Model -> Entry -> List ( Html Msg )
formFields model entry =
    [ Form.text"Title"
        [ value entry.title
        , onInput ( SetFormValue ( \v -> { entry | title = v } ) )
        , autofocus True
        ]
        []
    , div [] [
        label [] [ text "Date" ]
        , DatePicker.view model.date ( settings model.date ) model.datePicker
            |> Html.map DatePicker
    ]
    , Form.text "URL"
        [ value entry.url
        , onInput ( SetFormValue ( \v -> { entry | url = v } ) )
        ]
        []
    , Form.textarea "Comment"
        [ value entry.comment
        , onInput ( SetFormValue ( \v -> { entry | comment = v } ) )
        ]
        []
    , Form.float "Hours"
        [ value ( toString entry.hours )
        , onInput ( SetFormValue ( \v -> { entry | hours = Form.toFloat v } ) )
        ]
        []
    , Form.submit model.disabled Cancel
    ]



-- TABLE CONFIGURATION


config : Table.Config Entry Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
    { toId = .title
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Title" .title
        , Table.stringColumn "Date" .date
        , Table.stringColumn "URL" .url
        , Table.stringColumn "Comment" .comment
        , Table.floatColumn "Hours" .hours
        , customColumn "" ( viewButton Edit "Edit" )
        , customColumn "" ( viewButton Delete "Delete" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Entry -> List ( Attribute Msg )
toRowAttrs sport =
    [ style [ ( "background", "white" ) ]
    ]


customColumn : String -> ( Entry -> Table.HtmlDetails Msg ) -> Table.Column Entry Msg
customColumn name viewElement =
    Table.veryCustomColumn
        { name = name
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( Entry -> msg ) -> String -> Entry -> Table.HtmlDetails msg
viewButton msg name sport =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| sport ] [ text name ]
        ]


