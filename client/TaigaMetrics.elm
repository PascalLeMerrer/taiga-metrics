module TaigaMetrics exposing (main)

import ConnectionUpdates exposing (updateConnectionForm)
import Dict
import Navigation exposing (Location, program)
import Project exposing (..)
import MainView exposing (view)
import Route exposing (..)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
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


main =
    Navigation.program
        UrlChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
