module ConnectionAPi exposing (connect, disconnect)

import Http
import Json.Decode exposing (bool, decodeString, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode exposing (object, string)
import RemoteData.Http exposing (post, Config, deleteWithConfig)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)


connect : Model -> ( Model, Cmd Msg )
connect model =
    let
        body =
            Json.Encode.object
                [ ( "username", Json.Encode.string model.connection.username )
                , ( "password", Json.Encode.string model.connection.password )
                ]

        conn =
            model.connection
    in
        ( { model | connection = { conn | userStatus = Loading } }
        , post "/sessions" (ConnectionMsg << HandleLoginResponse) userDecoder body
        )


userDecoder : Decoder User
userDecoder =
    decode User
        -- fields MUST be in the same order than in the JSON response
        |> Pipeline.required "auth_token" Json.Decode.string
        |> Pipeline.required "full_display_name" Json.Decode.string
        |> Pipeline.required "username" Json.Decode.string


disconnect : Model -> ( Model, Cmd Msg )
disconnect model =
    let
        conn =
            model.connection
    in
        ( { model | connection = { conn | userStatus = Loading } }
        , deleteWithConfig (deleteConfig model) "/sessions" (ConnectionMsg << HandleLogoutResponse) (string "")
        )


deleteConfig : Model -> Config
deleteConfig model =
    { headers =
        [ Http.header "Accept" "application/json"
        , Http.header "Authorization" model.connection.token
        ]
    , withCredentials = False
    , timeout = Nothing
    }
