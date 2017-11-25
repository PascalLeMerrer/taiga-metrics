module Utils exposing (..)

import Html exposing (Attribute)
import Html.Attributes as Attr exposing (class)


-- join class names to create a class attribute value


classes : List String -> Attribute msg
classes styles =
    class <| String.join " " styles
