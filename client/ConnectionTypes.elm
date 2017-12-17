module ConnectionTypes exposing (..)

import Http
import RemoteData exposing (WebData)


type Msg
    = CloseMessage
    | Login
    | HandleLoginResponse (WebData User)
    | ChangeUsername String
    | ChangePassword String
    | TogglePasswordVisibility Bool


type alias Model =
    { authenticated : Bool
    , authenticationFailed : Bool
    , destinationUrl : String
    , username : String
    , user : WebData User
    , isPasswordVisible : Bool
    , password : String
    , serverError : Bool
    }


type alias User =
    { username : String
    , full_display_name : String
    , auth_token : String
    }


type alias Messages =
    { authenticationFailed :
        { title : String
        , body : String
        }
    , serverError :
        { title : String
        , body : String
        }
    , none :
        { title : String
        , body : String
        }
    }
