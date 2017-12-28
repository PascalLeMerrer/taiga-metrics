module ProjectView exposing (viewProject)

import Types exposing (Model, Msg)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import LogoutView exposing (viewLogoutButton)


viewProject : Model -> Html Msg
viewProject model =
    div []
        [ text "Project Detail"
        , viewLogoutButton model
        ]
