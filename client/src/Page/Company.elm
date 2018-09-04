module Page.Company exposing (Model, Msg, init, update, view)

import Data.Company exposing (Company, new)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Company
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Time
import Validate.Company
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal



-- MODEL


type alias Model =
    { errors : List ( Validate.Company.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe Company
    , disabled : Bool
    , companies : List Company

--    , showModal : ( Bool, Maybe Modal.Modal )
    }


type Action = None | Adding | Editing



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , companies = []

--    , showModal = ( False, Nothing )
    } ! [ Request.Company.list url |> Http.send FetchedCompany
        ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete Company
    | Deleted ( Result Http.Error Company )
    | Edit Company
    | Export Company
    | Exported ( Result Http.Error Company )
    | FetchedCompany ( Result Http.Error ( List Company ) )
--    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error Company )
    | PrintPreview Company
    | Put
    | Putted ( Result Http.Error Int )
    | SetFormValue ( String -> Company ) String
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

        Delete company ->
            { model |
                editing = company |> Just
--                , showModal = ( True, Nothing |> Modal.Delete |> Just )
            } ! []

        Deleted ( Ok deletedCompany ) ->
            { model |
                companies = model.companies |> List.filter ( \m -> deletedCompany.id /= m.id )
                , action = None
                , editing = Nothing
            } ! []

        Deleted ( Err err ) ->
            model ! []

        Edit company ->
            { model |
                action = Editing
                , editing = Just company
            } ! []

        Export company ->
            model !
            [
                company.id |> toString
                    |> Request.Company.export url
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

--        ModalMsg subMsg ->
--            let
--                pattern =
--                    model.showModal
--                        |> Tuple.second
--                        |> Maybe.withDefault ( Modal.Delete Nothing )
--
--                ( showModal, editing, cmd ) =
--                    case ( subMsg |> Modal.update, pattern ) of
--                        -- Delete
--                        ( True, Modal.Delete Nothing ) ->
--                            ( False
--                            , Nothing
--                            , Maybe.withDefault new model.editing
--                                |> Request.Company.delete url
--                                |> Http.toTask
--                                |> Task.attempt Deleted
--                            )
--
--                        -- PrintPreview, Close
--                        ( False, Modal.Preview ( Just company ) ) ->
--                            ( False
--                            , Nothing
--                            , Cmd.none
--                            )
--
--                        -- PrintPreview, Print
--                        ( True, Modal.Preview ( Just company ) ) ->
--                            ( False
--                            , Nothing
--                            , Maybe.withDefault new model.editing
--                                |> .id |> toString
--                                |> Request.Company.export url
--                                    |> Http.toTask
--                                    |> Task.attempt Exported
--                            )
--
--                        ( _, _ ) ->
--                            ( False
--                            , Nothing
--                            , Cmd.none
--                            )
--            in
--            { model |
--                showModal = ( showModal, Nothing )
--            } ! [ cmd ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just company ->
                            Validate.Company.errors company

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just company ->
                            ( None
                            , Request.Company.post url company
                                |> Http.toTask
                                |> Task.attempt Posted
                            )
                    else
                        ( Adding, Cmd.none )
            in
                { model |
                    action = action
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok company ) ->
            let
                companies =
                    case model.editing of
                        Nothing ->
                            model.companies

                        Just newCompany ->
                            model.companies
                                |> (::) { newCompany | id = company.id }
            in
            { model |
                companies = companies
                , editing = Nothing
            } ! []

        Posted ( Err err ) ->
            { model |
                editing = Nothing
            } ! []

        PrintPreview company ->
            { model |
                editing = company |> Just
--                , showModal = ( True, company |> Just |> Modal.Preview |> Just )
            } ! []

        Put ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just company ->
                            Validate.Company.errors company

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just company ->
                            ( None
                            , Request.Company.put url company
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
                companies =
                    case model.editing of
                        Nothing ->
                            model.companies

                        Just newCompany ->
                            model.companies
                                |> (::) { newCompany | id = id }
                newCompany =
                    case model.editing of
                        -- TODO
                        Nothing ->
                            new

                        Just company ->
                            company
            in
            { model |
                companies =
                    model.companies
                        |> List.filter ( \m -> newCompany.id /= m.id )
                        |> (::) newCompany
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
            [ h1 [] [ text "Companies" ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView model =
    let
        editable : Company
        editable = case model.editing of
            Nothing ->
                new

            Just company ->
                company
    in
    case model.action of
        None ->
            [ button [ onClick Add ] [ text "Add Company" ]
            , Table.view config model.tableState model.companies
--            , model.showModal
--                |> Modal.view model.editing
--                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( formFields model editable )
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( formFields model editable )
            ]


formFields : Model -> Company -> List ( Html Msg )
formFields model company =
    [ Form.text "Name"
        [ value company.name
        , onInput ( SetFormValue ( \v -> { company | name = v } ) )
        , autofocus True
        ]
        []
    , Form.text "URL"
        [ value company.url
        , onInput ( SetFormValue ( \v -> { company | url = v } ) )
        ]
        []
    , Form.textarea "Comment"
        [ value company.comment
        , onInput ( SetFormValue ( \v -> { company | comment = v } ) )
        ]
        []
    ]



-- TABLE CONFIGURATION


config : Table.Config Company Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
    { toId = .name
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Name" .name
        , Table.stringColumn "URL" .url
        , Table.stringColumn "Comment" .comment
        , customColumn "" ( viewButton Edit "Edit" )
        , customColumn "" ( viewButton Delete "Delete" )
        , customColumn "" ( viewButton PrintPreview "Print Preview" )
        , customColumn "" ( viewButton Export "Export" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Company -> List ( Attribute Msg )
toRowAttrs sport =
    [ style [ ( "background", "white" ) ]
    ]


customColumn : String -> ( Company -> Table.HtmlDetails Msg ) -> Table.Column Company Msg
customColumn name viewElement =
    Table.veryCustomColumn
        { name = name
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( Company -> msg ) -> String -> Company -> Table.HtmlDetails msg
viewButton msg name company =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| company ] [ text name ]
        ]


