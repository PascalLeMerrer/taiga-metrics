module ConnectionTypes exposing (..)

import Http


type Msg
    = CloseMessage
    | Login
    | Logged (Result Http.Error User)
    | ChangeEmail String
    | ChangePassword String
    | TogglePasswordVisibility Bool


type alias Model =
    { authenticated : Bool
    , authenticationFailed : Bool
    , destinationUrl : String
    , email : String
    , isPasswordVisible : Bool
    , isWaitingConnect : Bool
    , password : String
    , serverError : Bool
    }


type alias User =
    { email : String
    , username : String
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
