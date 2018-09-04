module Views.Page exposing (ActivePage(..), frame)

import Html exposing (Html, a, div, footer, li, main_, nav, p, text, ul)
import Html.Attributes exposing (class, classList, id)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | Company
    | Invoice
    | Entry


type alias SiteLink msg =
    { page : ActivePage
    , route : Route
    , content : List ( Html msg )
    }


siteLinks : ActivePage -> List ( SiteLink a )
siteLinks page =
    [ SiteLink Home Route.Home [ text "Home" ]
    , SiteLink Company Route.Company [ text "Companies" ]
    , SiteLink Invoice Route.Invoice [ text "Invoices" ]
    , SiteLink Entry Route.Entry [ text "Entries" ]
    ]


frame : ActivePage -> Html msg -> Html msg
frame page content =
    -- Add a page id to be able to target the current page (see navbar.css).
    main_ [ id ( ( toString page ) |> String.toLower ), class "page-frame" ]
        [ viewHeader page
        , content
        , viewFooter
        ]


viewHeader : ActivePage -> Html msg
viewHeader page =
    nav [ class "navbar" ]
        [ div [ class "container" ]
            [ ul [ class "nav" ] <|
                ( siteLinks page
                    |> List.map ( navbarLink <| page )
                )
            ]

        ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ] []
        ]


navbarLink : ActivePage -> ( SiteLink a ) -> Html a
navbarLink currentPage { page, route, content } =
    li [ classList [ ( "nav-item", True ), ( "active", (==) currentPage page ) ] ]
        [ a [ class "nav-link", Route.href route ] content ]


