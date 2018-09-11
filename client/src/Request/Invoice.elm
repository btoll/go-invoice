module Request.Invoice exposing (delete, list, post, export, put)

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


export : String -> String -> Http.Request Invoice
export url invoice_id =
    decoder
        |> Http.get (
            (++) "/invoice/export/" invoice_id
                |> (++) url
            )


--get : String -> String -> Http.Request ( List Invoice )
--get url company_id =
--    manyDecoder
--        |> Http.get ( url ++ "/invoice/list/" ++ company_id )


list : String -> String -> Http.Request ( List Invoice )
list url company_id =
    manyDecoder
        |> Http.get ( url ++ "/invoice/list/" ++ company_id )


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


