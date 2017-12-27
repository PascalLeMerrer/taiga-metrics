module MainView exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import LoginView
import ProjectListView
import ProjectView
import RemoteData exposing (RemoteData(Failure))
import Route exposing (Page(..))
import ViewUtils exposing (classes)


view : Model -> Html Msg
view model =
    div []
        [ viewColumns <|
            case model.currentPage of
                HomePage ->
                    LoginView.viewLoginForm model

                ProjectsPage projectSummaryList ->
                    ProjectListView.viewProjectList model

                ProjectDetailPage projectId project ->
                    ProjectView.viewProject model
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


viewMessage : Model -> Html Msg
viewMessage model =
    let
        messageClass =
            case model.userMessage.messageType of
                SuccessMessage ->
                    "is-success"

                ErrorMessage ->
                    "is-danger"

                NoMessage ->
                    ""
    in
        if model.userMessage.messageType == NoMessage then
            span [] []
        else
            article [ classes [ "message", messageClass ] ]
                [ div [ class "message-header" ]
                    [ p [] [ text model.userMessage.title ]
                    , button [ class "delete", onClick CloseMessage ] []
                    ]
                , div [ class "message-body" ]
                    [ text model.userMessage.body ]
                ]
