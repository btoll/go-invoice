module Request.Entry exposing (delete, get, post, put)

import Http
import Data.Entry exposing (Entry, decoder, encoder, manyDecoder, succeed)



delete : String -> Entry -> Http.Request Entry
delete url entry =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/entry/" ) ( toString entry.id )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed entry )
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> String -> Http.Request ( List Entry )
get url invoice_id =
    manyDecoder
        |> Http.get ( url ++ "/entry/list/" ++ invoice_id )


post : String -> Entry -> Http.Request Entry
post url entry =
    let
        body : Http.Body
        body =
            encoder entry
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/entry/" ) body


put : String -> Entry -> Http.Request Int
put url entry =
    let
        body : Http.Body
        body =
            encoder entry
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/entry/" ) ( toString entry.id ) )
            , body = body
            , expect = Http.expectJson ( entry.id |> succeed )
            , timeout = Nothing
            , withCredentials = False
            }


