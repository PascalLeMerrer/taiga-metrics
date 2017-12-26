module TaigaMetrics exposing (main)

import ConnectionTypes exposing (..)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (bool, decodeString, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode exposing (object, string)
import Navigation exposing (Location, program)
import Project exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (post, Config, deleteWithConfig)
import Route exposing (..)
import Utils exposing (classes)


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


view : Model -> Html Msg
view model =
    div []
        [ viewColumns <|
            case model.currentPage of
                HomePage ->
                    viewLoginForm model

                ProjectsPage projectSummaryList ->
                    viewProjectList model

                ProjectDetailPage projectId project ->
                    viewProjectDetail model
        , viewColumns <| viewMessage model
        ]


viewColumns : Html Msg -> Html Msg
viewColumns centralColumContent =
    div [ class "columns" ]
        [ div [ class "column" ] []
        , div [ class "column" ]
            [ centralColumContent ]
        , div [ class "column" ] []
        ]


viewLoginForm : Model -> Html Msg
viewLoginForm model =
    Html.form [ onSubmit Login ]
        [ viewInputField <| viewUsernameField model
        , viewInputField <| viewPasswordField model
        , viewVisibilityCheckbox model
        , viewLoginButton model
        ]


viewInputField : ( String, List (Html Msg) ) -> Html Msg
viewInputField content =
    div [ class "fied" ]
        [ label [ class "label" ] [ text <| Tuple.first content ]
        , p [ class "control has-icons-left" ] <| Tuple.second content
        ]


viewUsernameField : Model -> ( String, List (Html Msg) )
viewUsernameField model =
    ( "Nom d'utilisateur"
    , [ input
            [ class "input"
            , onInput ChangeUsername
            ]
            []
      ]
    )


viewPasswordField : Model -> ( String, List (Html Msg) )
viewPasswordField model =
    ( "Mot de passe"
    , [ input
            [ class "input"
            , type_ <| viewPasswordType model
            , onInput ChangePassword
            ]
            []
      , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-lock" ] []
            ]
      ]
    )


viewVisibilityCheckbox : Model -> Html Msg
viewVisibilityCheckbox model =
    div [ class "field" ]
        [ label [ class "checkbox" ]
            []
        , input
            [ checked model.isPasswordVisible
            , type_ "checkbox"
            , onClick <| TogglePasswordVisibility <| not model.isPasswordVisible
            ]
            []
        , text " Afficher le mot de passe"
        ]


viewLoginButton : Model -> Html Msg
viewLoginButton model =
    let
        loginButtonClass =
            [ "button"
            , "is-primary"
            , if model.user == Loading then
                "is-loading"
              else
                ""
            ]
    in
        div [ classes [ "field has-addons-centered" ] ]
            [ p [ class "control" ]
                [ button
                    [ classes loginButtonClass
                    ]
                    [ text "Me connecter" ]
                ]
            ]


viewPasswordType : Model -> String
viewPasswordType model =
    if model.isPasswordVisible then
        "text"
    else
        "password"


viewLogoutButton : Model -> Html Msg
viewLogoutButton model =
    let
        logoutButtonClass =
            [ "button"
            , if model.user == Loading then
                "is-loading"
              else
                ""
            ]
    in
        div [ classes [ "field has-addons-centered" ] ]
            [ p [ class "control" ]
                [ button
                    [ classes logoutButtonClass
                    , onClick Logout
                    ]
                    [ text "Me déconnecter" ]
                ]
            ]


viewProjectList : Model -> Html Msg
viewProjectList model =
    div []
        [ text "Project List"
        , viewLogoutButton model
        ]


viewProjectDetail : Model -> Html Msg
viewProjectDetail model =
    div []
        [ text "Project Detail"
        , viewLogoutButton model
        ]


messages : Messages
messages =
    { authenticationFailed =
        { title = "La connexion a échoué"
        , body = "Cette combinaison nom d'utilisateur / mot de passe est erronée."
        }
    , serverError =
        { title = "Une erreur est survenue"
        , body = "Une erreur est survenue. Veuillez vérifier votre connexion avant de tenter à nouveau. Si l'erreur persiste, veuillez utiliser le formulaire de contact du site pour nous le signaler."
        }
    , none =
        { title = ""
        , body = ""
        }
    }


viewMessage : Model -> Html Msg
viewMessage model =
    let
        -- todo use a record
        message =
            case model.user of
                Failure (Http.BadStatus response) ->
                    if response.status.code < 500 then
                        messages.authenticationFailed
                    else
                        messages.serverError

                _ ->
                    messages.none

        hasError =
            message /= messages.none

        hasSuccess =
            False

        -- no success message by now
        messageClass =
            if hasSuccess then
                "is-success"
            else
                "is-danger"
    in
        if hasError || hasSuccess then
            article [ classes [ "message", messageClass ] ]
                [ div [ class "message-header" ]
                    [ p [] [ text message.title ]
                    , button [ class "delete", onClick CloseMessage ] []
                    ]
                , div [ class "message-body" ]
                    [ text message.body ]
                ]
        else
            span [] []


main =
    Navigation.program
        UrlChanged
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
