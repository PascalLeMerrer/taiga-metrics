module Types exposing (..)

import Http
import Navigation exposing (Location)
import Project exposing (..)
import RemoteData exposing (WebData)
import Route exposing (Page)


type alias Model =
    { connection : Connection
    , currentPage : Page
    , projects : List ProjectSummary
    , userMessage : UserMessage
    }


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


type alias Connection =
    { authenticated : Bool
    , isPasswordVisible : Bool
    , password : String
    , token : String
    , userStatus : WebData User
    , username : String
    }


type alias User =
    { auth_token : String
    , full_display_name : String
    , username : String
    }


type alias UserMessage =
    { body : String
    , title : String
    , messageType : UserMessageType
    }


type UserMessageType
    = SuccessMessage
    | ErrorMessage
    | NoMessage
