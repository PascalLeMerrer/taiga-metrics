module LogoutView exposing (viewLogoutButton)

import ConnectionTypes exposing (Model, Msg(Logout))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import RemoteData exposing (RemoteData(..))
import ViewUtils exposing (classes)


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
