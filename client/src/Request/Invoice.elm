module Request.Invoice exposing (delete, list, post, print, put)

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


get : String -> String -> Http.Request ( List Invoice )
get url method =
    manyDecoder
        |> Http.get ( url ++ "/invoice/" ++ method )


list : String -> Http.Request ( List Invoice )
list url =
    "list"
        |> get url


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


print : String -> String -> Http.Request ( List Invoice )
print url invoice_id =
    (++) "print/" invoice_id
        |> get url


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


