module ConnectionUpdates exposing (updateConnectionForm)

import ConnectionAPi exposing (connect, disconnect)
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (Page(HomePage, ProjectsPage))
import Types exposing (..)
import UserMessages exposing (..)


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
                    , userMessage = emptyUserMessage
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
