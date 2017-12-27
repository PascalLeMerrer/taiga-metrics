module UserMessages exposing (..)

import Types exposing (UserMessage, UserMessageType(..))


emptyUserMessage : UserMessage
emptyUserMessage =
    { title = ""
    , body = ""
    , messageType = NoMessage
    }


serverErrorMessage : UserMessage
serverErrorMessage =
    { title = "Une erreur est survenue"
    , body =
        "Une erreur est survenue. Veuillez vérifier votre connexion avant de tenter à nouveau. "
            ++ "Si l'erreur persiste, veuillez utiliser le formulaire de contact du site pour nous le signaler."
    , messageType = ErrorMessage
    }


authenticationFailedMessage : UserMessage
authenticationFailedMessage =
    { title = "La connexion a échoué"
    , body = "Cette combinaison nom d'utilisateur / mot de passe est erronée."
    , messageType = ErrorMessage
    }


deconnectionErrorMessage : UserMessage
deconnectionErrorMessage =
    { title = "La déconnexion a échoué"
    , body = ""
    , messageType = ErrorMessage
    }
