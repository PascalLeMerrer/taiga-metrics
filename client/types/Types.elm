module Types exposing (..)

import Http
import Navigation exposing (Location)
import Project exposing (..)
import RemoteData exposing (WebData)
import Route exposing (Page)


type Msg
    = CloseMessage
    | ConnectionMsg ConnectionMsg
    | UrlChanged Location


type ConnectionMsg
    = ChangePassword String
    | ChangeUsername String
    | HandleLoginResponse (WebData User)
    | HandleLogoutResponse (WebData String)
    | Login
    | Logout
    | TogglePasswordVisibility Bool


type alias Model =
    { authenticated : Bool
    , currentPage : Page
    , isPasswordVisible : Bool
    , password : String
    , projects : List ProjectSummary
    , token : String
    , userStatus : WebData User
    , username : String
    }


type alias User =
    { auth_token : String
    , full_display_name : String
    , username : String
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
