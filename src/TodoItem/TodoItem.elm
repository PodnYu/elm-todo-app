module TodoItem.TodoItem exposing (..)


type alias TodoItem =
    { id : String
    , title : String
    , description : String
    , checked : Bool
    }
