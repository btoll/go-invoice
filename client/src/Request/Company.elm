module Request.Company exposing (delete, list, post, export, put)

import Http
import Data.Company exposing (Company, decoder, encoder, manyDecoder, succeed)



delete : String -> Company -> Http.Request Company
delete url company =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/company/" ) ( toString company.id )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed company )
        , timeout = Nothing
        , withCredentials = False
        }


export : String -> String -> Http.Request Company
export url invoice_id =
    decoder
        |> Http.get (
            (++) "/company/export/" invoice_id
                |> (++) url
            )


get : String -> String -> Http.Request ( List Company )
get url method =
    manyDecoder
        |> Http.get ( url ++ "/company/" ++ method )


list : String -> Http.Request ( List Company )
list url =
    "list"
        |> get url


post : String -> Company -> Http.Request Company
post url company =
    let
        body : Http.Body
        body =
            encoder company
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/company/" ) body


put : String -> Company -> Http.Request Int
put url company =
    let
        body : Http.Body
        body =
            encoder company
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/company/" ) ( toString company.id ) )
            , body = body
            , expect = Http.expectJson ( company.id |> succeed )
            , timeout = Nothing
            , withCredentials = False
            }


