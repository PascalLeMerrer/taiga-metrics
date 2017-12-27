module TaigaMetrics exposing (main)

import MainView exposing (view)
import Types exposing (..)
import Dict
import Http
import Json.Decode exposing (bool, decodeString, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode exposing (object, string)
import Navigation exposing (Location, program)
import Project exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (post, Config, deleteWithConfig)
import Route exposing (..)
import UserMessages exposing (..)


initialConnection : Connection
initialConnection =
    { authenticated = False
    , isPasswordVisible = False
    , password = ""
    , token = ""
    , username = ""
    , userStatus = NotAsked
    }


init : Location -> ( Model, Cmd Msg )
init location =
    { connection = initialConnection
    , currentPage = HomePage
    , projects = []
    , userMessage = emptyUserMessage
    }
        |> urlUpdate location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CloseMessage ->
            let
                conn =
                    model.connection
            in
                ( { model | connection = { conn | userStatus = NotAsked } }, Cmd.none )

        ConnectionMsg connectionMsg ->
            updateConnectionForm connectionMsg model

        UrlChanged newLocation ->
            urlUpdate newLocation model


updateConnectionForm : ConnectionMsg -> Model -> ( Model, Cmd Msg )
updateConnectionForm msg model =
    let
        conn =
            model.connection
    in
        case msg of
            ChangeUsername login ->
                ( { model | connection = { conn | username = login } }, Cmd.none )

            ChangePassword pass ->
                ( { model | connection = { conn | password = pass } }, Cmd.none )

            Login ->
                connect model

            HandleLoginResponse NotAsked ->
                ( { model
                    | connection = { conn | userStatus = NotAsked }
                    , userMessage = emptyUserMessage
                  }
                , Cmd.none
                )

            HandleLoginResponse (Failure httpError) ->
                ( { model
                    | connection = { conn | userStatus = Failure httpError }
                    , userMessage = authenticationFailedMessage
                  }
                , Cmd.none
                )

            HandleLoginResponse (Success user) ->
                ( { model
                    | connection =
                        { conn
                            | authenticated = True
                            , userStatus = Success user
                            , token = user.auth_token
                        }
                    , currentPage = ProjectsPage []
                  }
                , Cmd.none
                )

            Logout ->
                disconnect model

            HandleLogoutResponse (Success _) ->
                ( { model
                    | connection = { conn | authenticated = False, userStatus = NotAsked }
                    , userMessage = emptyUserMessage
                    , currentPage = HomePage
                  }
                , Cmd.none
                )

            HandleLogoutResponse (Failure httpError) ->
                ( { model
                    | connection = { conn | userStatus = Failure httpError }
                    , userMessage = { deconnectionErrorMessage | body = toString httpError }
                  }
                , Cmd.none
                )

            TogglePasswordVisibility value ->
                ( { model | connection = { conn | isPasswordVisible = value } }, Cmd.none )

            _ ->
                ( model, Cmd.none )


urlUpdate : Location -> Model -> ( Model, Cmd Msg )
urlUpdate newLocation model =
    case Route.parse newLocation of
        Nothing ->
            ( model
              -- { model | message = "invalid URL: " ++ newLocation.hash }
            , Route.modifyUrl model.currentPage
            )

        Just validRoute ->
            if Route.isEqual validRoute model.currentPage then
                ( model, Cmd.none )
            else
                case validRoute of
                    Home ->
                        ( { model | currentPage = HomePage }
                        , Cmd.none
                        )

                    Projects ->
                        ( { model
                            | currentPage = ProjectsPage model.projects
                          }
                        , Cmd.none
                        )

                    ProjectDetail id ->
                        ( -- { model
                          --    | serverRequest = Just id
                          --    , message =
                          --        "Loading data for project: " ++ toString id
                          -- }
                          model
                        , Route.modifyUrl model.currentPage
                        )


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


deleteConfig : Model -> Config
deleteConfig model =
    { headers =
        [ Http.header "Accept" "application/json"
        , Http.header "Authorization" model.connection.token
        ]
    , withCredentials = False
    , timeout = Nothing
    }


disconnect : Model -> ( Model, Cmd Msg )
disconnect model =
    let
        conn =
            model.connection
    in
        ( { model | connection = { conn | userStatus = Loading } }
        , deleteWithConfig (deleteConfig model) "/sessions" (ConnectionMsg << HandleLogoutResponse) (string "")
        )


userDecoder : Decoder User
userDecoder =
    decode User
        -- fields MUST be in the same order than in the JSON response
        |> Pipeline.required "auth_token" Json.Decode.string
        |> Pipeline.required "full_display_name" Json.Decode.string
        |> Pipeline.required "username" Json.Decode.string


main =
    Navigation.program
        UrlChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
