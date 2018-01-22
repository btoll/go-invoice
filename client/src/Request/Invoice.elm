module Request.Invoice exposing (delete, get, post, put)

import Http
import Data.Invoice exposing (Invoice, decoder, encoder, manyDecoder, succeed)



delete : String -> Invoice -> Http.Request Invoice
delete url invoice =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/invoice/" ) ( toString invoice.id )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed invoice )
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> Http.Request ( List Invoice )
get url =
    manyDecoder
        |> Http.get ( (++) url "/invoice/list" )


post : String -> Invoice -> Http.Request Invoice
post url invoice =
    let
        body : Http.Body
        body =
            encoder invoice
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/invoice/" ) body


put : String -> Invoice -> Http.Request Int
put url invoice =
    let
        body : Http.Body
        body =
            encoder invoice
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/invoice/" ) ( toString invoice.id ) )
            , body = body
            , expect = Http.expectJson ( invoice.id |> succeed )
            , timeout = Nothing
            , withCredentials = False
            }


