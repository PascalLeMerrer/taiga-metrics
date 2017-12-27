module LoginView exposing (viewLoginForm)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import RemoteData exposing (RemoteData(..))
import ViewUtils exposing (classes)


viewLoginForm : Model -> Html Msg
viewLoginForm model =
    Html.form [ onSubmit <| ConnectionMsg Login ]
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
            , onInput (ConnectionMsg << ChangeUsername)
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
            , onInput (ConnectionMsg << ChangePassword)
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
            , onClick <| ConnectionMsg (TogglePasswordVisibility <| not model.isPasswordVisible)
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
