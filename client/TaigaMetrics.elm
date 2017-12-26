module TaigaMetrics exposing (main)

import MainView exposing (view)
import ConnectionTypes exposing (..)
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


init : Location -> ( Model, Cmd Msg )
init location =
    { authenticated = False
    , currentPage = HomePage
    , isPasswordVisible = False
    , password = ""
    , projects = []
    , token = ""
    , username = ""
    , user = NotAsked
    }
        |> urlUpdate location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updateConnectionForm msg model


updateConnectionForm : Msg -> Model -> ( Model, Cmd Msg )
updateConnectionForm msg model =
    case msg of
        ChangeUsername login ->
            ( { model | username = login }, Cmd.none )

        ChangePassword pass ->
            ( { model | password = pass }, Cmd.none )

        CloseMessage ->
            ( { model | user = NotAsked }, Cmd.none )

        Login ->
            connect model

        HandleLoginResponse NotAsked ->
            ( { model | user = NotAsked }, Cmd.none )

        HandleLoginResponse Loading ->
            ( model, Cmd.none )

        HandleLoginResponse (Failure httpError) ->
            ( { model | user = Failure httpError }, Cmd.none )

        HandleLoginResponse (Success user) ->
            ( { model
                | authenticated = True
                , user = Success user
                , token = user.auth_token
                , currentPage = ProjectsPage []
              }
            , Cmd.none
            )

        Logout ->
            disconnect model

        HandleLogoutResponse _ ->
            ( { model | authenticated = False, user = NotAsked, currentPage = HomePage }, Cmd.none )

        TogglePasswordVisibility value ->
            ( { model | isPasswordVisible = value }, Cmd.none )

        UrlChanged newLocation ->
            urlUpdate newLocation model


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
                [ ( "username", Json.Encode.string model.username )
                , ( "password", Json.Encode.string model.password )
                ]
    in
        ( { model | user = Loading }
        , post "/sessions" HandleLoginResponse userDecoder body
        )


deleteConfig : Model -> Config
deleteConfig model =
    { headers =
        [ Http.header "Accept" "application/json"
        , Http.header "Authorization" model.token
        ]
    , withCredentials = False
    , timeout = Nothing
    }


disconnect : Model -> ( Model, Cmd Msg )
disconnect model =
    ( { model | user = Loading }
    , deleteWithConfig (deleteConfig model) "/sessions" HandleLogoutResponse (string "")
    )


userDecoder : Decoder User
userDecoder =
    decode User
        |> Pipeline.required "username" Json.Decode.string
        |> Pipeline.required "full_display_name" Json.Decode.string
        |> Pipeline.required "auth_token" Json.Decode.string


main =
    Navigation.program
        UrlChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
