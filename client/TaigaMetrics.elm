module TaigaMetrics exposing (main)

import ConnectionTypes exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (bool, decodeString, Decoder, string)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode exposing (object, string)
import Navigation
import Utils exposing (classes)


initialModel : Model
initialModel =
    { authenticated = False
    , authenticationFailed = False
    , destinationUrl = "/"
    , email = ""
    , isPasswordVisible = False
    , isWaitingConnect = False
    , password = ""
    , serverError = False
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updateConnectionForm msg model


updateConnectionForm : Msg -> Model -> ( Model, Cmd Msg )
updateConnectionForm msg model =
    case msg of
        ChangeEmail login ->
            ( { model | email = login }, Cmd.none )

        ChangePassword pass ->
            ( { model | password = pass }, Cmd.none )

        CloseMessage ->
            ( { model
                | authenticationFailed = False
                , serverError = False
              }
            , Cmd.none
            )

        Logged (Err httpError) ->
            let
                authenticationFailed =
                    case httpError of
                        Http.BadStatus response ->
                            response.status.code < 500

                        _ ->
                            False

                serverError =
                    not authenticationFailed
            in
                ( { model
                    | authenticationFailed = authenticationFailed
                    , isWaitingConnect = False
                    , serverError = serverError
                  }
                , Cmd.none
                )

        Logged (Ok user) ->
            ( { model
                | authenticated = True
                , authenticationFailed = False
                , isWaitingConnect = False
                , serverError = False
              }
            , Navigation.load model.destinationUrl
            )

        Login ->
            connect model

        TogglePasswordVisibility value ->
            ( { model | isPasswordVisible = value }, Cmd.none )


connect : Model -> ( Model, Cmd Msg )
connect model =
    let
        body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "email", Json.Encode.string model.email )
                    , ( "password", Json.Encode.string model.password )
                    ]

        updatedModel =
            { model
                | isWaitingConnect = True
                , authenticationFailed = False
                , serverError = False
            }
    in
        ( updatedModel
        , userDecoder
            |> Http.post "/sessions" body
            |> Http.send Logged
        )


userDecoder : Decoder User
userDecoder =
    decode User
        |> Pipeline.required "email" Json.Decode.string
        |> Pipeline.required "username" Json.Decode.string
        |> Pipeline.required "full_display_name" Json.Decode.string
        |> Pipeline.required "auth_token" Json.Decode.string


view : Model -> Html Msg
view model =
    div []
        [ viewColumns <|
            Html.form [ onSubmit Login ]
                [ viewInputField <| viewEmailField model
                , viewInputField <| viewPasswordField model
                , viewVisibilityCheckbox model
                , viewLoginButton model
                ]
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


viewInputField : ( String, List (Html Msg) ) -> Html Msg
viewInputField content =
    div [ class "fied" ]
        [ label [ class "label" ] [ text <| Tuple.first content ]
        , p [ class "control has-icons-left" ] <| Tuple.second content
        ]


viewEmailField : Model -> ( String, List (Html Msg) )
viewEmailField model =
    ( "Adresse email"
    , [ input
            [ type_ "email"
            , class <| viewInputFieldStyle model
            , onInput ChangeEmail
            ]
            []
      , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-envelope" ] []
            ]
      ]
    )


viewPasswordField : Model -> ( String, List (Html Msg) )
viewPasswordField model =
    ( "Mot de passe"
    , [ input
            [ class <| viewInputFieldStyle model
            , type_ <| viewPasswordType model
            , onInput ChangePassword
            ]
            []
      , span [ class "icon is-small is-left" ]
            [ i [ class "fa fa-lock" ] []
            ]
      ]
    )


viewInputFieldStyle : Model -> String
viewInputFieldStyle model =
    if model.authenticationFailed then
        "input is-danger"
    else
        "input"


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
            , if model.isWaitingConnect then
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


messages : Messages
messages =
    { authenticationFailed =
        { title = "La connexion a échoué"
        , body = "Cette combinaison email / mot de passe est erronée."
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
            if model.authenticationFailed then
                messages.authenticationFailed
            else if model.serverError then
                messages.serverError
            else
                messages.none

        hasError =
            model.authenticationFailed || model.serverError

        hasSuccess =
            False

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


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
