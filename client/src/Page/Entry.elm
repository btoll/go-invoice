module Page.Entry exposing (Model, Msg, init, update, view)

import Data.Company exposing (Company)
import Data.Entry exposing (Entry, new)
import Data.Invoice exposing (Invoice)
import Data.PrintPreview
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, span, text)
import Html.Attributes exposing (action, autofocus, checked, class, cols, disabled, for, rows, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Company
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

    , companies : List Company
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

    , companies = []
    , entries = []
    , invoices = []
    , selectedInvoiceID = -1

    , date = Nothing
    , datePicker = datePicker
    , showModal = ( False, Nothing )
    } ! [ Cmd.map DatePicker datePickerFx
        , "-1"
            |> Request.Invoice.list url
            |> Http.send FetchedInvoice
        , Request.Company.list url |> Http.send FetchedCompany
        ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete Entry
    | Deleted ( Result Http.Error Entry )
    | Edit Entry
    | Export Invoice
    | Exported ( Result Http.Error Invoice )
    | FetchedCompany ( Result Http.Error ( List Company ) )
    | FetchedEntry ( Result Http.Error ( List Entry ) )
    | FetchedInvoice ( Result Http.Error ( List Invoice ) )
    | InvoiceSelected String
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error Entry )
    | PrintPreview Invoice
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
                pattern =
                    model.showModal
                        |> Tuple.second
                        |> Maybe.withDefault ( Modal.Delete Nothing )

                ( showModal, cmd ) =
                    case ( subMsg |> Modal.update, pattern ) of
                        -- Delete
                        ( False, Modal.Delete Nothing ) ->
                            ( False
                            , Cmd.none
                            )

                        ( True, Modal.Delete Nothing ) ->
                            ( True
                            , Maybe.withDefault new model.editing
                                |> Request.Entry.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
                            )

                        -- PrintPreview, Close
                        ( False, Modal.PrintPreview ( Just invoice ) ) ->
                            ( False
                            , Cmd.none
                            )

                        -- PrintPreview, Print
                        ( True, Modal.PrintPreview ( Just invoice ) ) ->
                            ( False
                            , model.selectedInvoiceID
                                |> toString
                                |> Request.Invoice.export url
                                    |> Http.toTask
                                    |> Task.attempt Exported
                            )

                        ( _, _ ) ->
                            ( False
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

        PrintPreview invoice ->
            let
                getCompany companies =
                    companies
                        |> List.filter ( \company -> invoice.company_id |> (==) company.id )
                        |> List.head
                        |> Maybe.withDefault Data.Company.new
            in
            { model |
                showModal =
                    ( True
                    , invoice |>
                        Data.PrintPreview.PrintPreview ( model.companies |> getCompany )
                        |> Just
                        |> Modal.PrintPreview
                        |> Just
                    )
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

        getCompanyName: Int -> String
        getCompanyName id =
            model.companies
                |> List.filter ( \c -> (==) c.id id )
                |> List.head
                |> Maybe.withDefault Data.Company.new
                >> .name

        options : List Invoice -> List ( Html Msg )
        options invoices =
            invoices
                |> List.map ( \m -> ( m.id |> toString, ( m.company_id |> getCompanyName ) ++ " | " ++ m.dateFrom ++ " <> " ++ m.dateTo ) )
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
            let
                invoice =
                    model.invoices
                        |> List.filter ( \invoice -> (==) invoice.id model.selectedInvoiceID )
                        |> List.head
                        |> Maybe.withDefault Data.Invoice.new
            in
            [ selectInvoice
            , button [ Add |> onClick ] [ "Add Entry" |> text ]
            , button [ style [ ( "marginLeft", "10px" ) ], invoice |> PrintPreview |> onClick ] [ "Print Preview" |> text ]
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
    , Form.textarea "Reference"
        [ value ( entry.reference |> String.join ", " )
        , onInput ( SetFormValue ( \v -> { entry | reference = ( v |> String.split "," ) } ) )
--        , 80 |> cols
--        , 5 |> rows
        ]
        []
    , Form.textarea "Notes"
        [ value entry.notes
        , onInput ( SetFormValue ( \v -> { entry | notes = v } ) )
        , 80 |> cols
        , 20 |> rows
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
        , customColumn "Reference" viewReferences
        , customColumn "Notes" viewNotes
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


--viewAmount : Entry -> Table.HtmlDetails msg
--viewAmount { rate, hours } =
--    Table.HtmlDetails []
--        [ span [] [ ( (*) rate hours ) |> toString |> text ]
--        ]


viewButton : ( Entry -> msg ) -> String -> Entry -> Table.HtmlDetails msg
viewButton msg name sport =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| sport ] [ text name ]
        ]


-- TODO: DRY!!
viewNotes : Entry -> Table.HtmlDetails Msg
viewNotes { notes } =
    Table.HtmlDetails [ [ ( "width", "30%" ) ] |> style ]
        [ div [ "notes" |> class ] [ notes |> text ]
        ]

viewReferences : Entry -> Table.HtmlDetails Msg
viewReferences { reference } =
    let
        -- If we dont' separate the URLs by a space, it will be one long word that will
        -- blow out the table.
        separateBySpace v acc =
            (++) acc
                ( (++) v " "
                )
    in
    Table.HtmlDetails [ [ ( "width", "30%" ) ] |> style ]
        [ div [ "notes" |> class ] [ ( reference |> List.foldl separateBySpace "" ) |> text ]
        ]
-------------


