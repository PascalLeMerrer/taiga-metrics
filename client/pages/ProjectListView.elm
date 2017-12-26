module ProjectListView exposing (viewProjectList)

import ConnectionTypes exposing (Model, Msg)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import LogoutView exposing (viewLogoutButton)


viewProjectList : Model -> Html Msg
viewProjectList model =
    div []
        [ text "Project List"
        , viewLogoutButton model
        ]
