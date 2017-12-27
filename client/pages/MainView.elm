module MainView exposing (..)

import Types exposing (Model, Msg(CloseMessage), Messages)
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
