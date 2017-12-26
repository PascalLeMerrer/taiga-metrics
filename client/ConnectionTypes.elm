module ConnectionTypes exposing (..)

import Http
import Navigation exposing (Location)
import Project exposing (..)
import RemoteData exposing (WebData)
import Route exposing (Page)


type Msg
    = CloseMessage
    | Login
    | HandleLoginResponse (WebData User)
    | Logout
    | HandleLogoutResponse (WebData String)
    | ChangeUsername String
    | ChangePassword String
    | TogglePasswordVisibility Bool
    | UrlChanged Location


type alias Model =
    { authenticated : Bool
    , currentPage : Page
    , username : String
    , user : WebData User
    , isPasswordVisible : Bool
    , password : String
    , projects : List ProjectSummary
    , token : String
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
