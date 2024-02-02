module TodoItem.CreateDialog exposing (..)

import Common.Dialog as Dialog
import Html exposing (Html, button, div, input, text, textarea)
import Html.Attributes exposing (class, id, placeholder, value)
import Html.Events exposing (onClick, onInput)


type alias Config =
    { open : Bool
    , title : String
    , description : String
    }


type Msg
    = Update Config
    | Submit Config
    | ClickAway
    | NoOp


view : Config -> (Msg -> msg) -> Html msg
view config toMsg =
    Dialog.view
        { open = config.open
        , classList = [ ( "create-todo-item-modal__body", True ) ]
        , onClickAway = toMsg ClickAway
        , noOp = toMsg NoOp
        }
        [ div [ class "create-todo-item-modal__header" ]
            [ text "Create a todo item" ]
        , input [ value config.title, placeholder "title...", onInput (\v -> toMsg (Update (updateTitle v config))) ] []
        , textarea [ value config.description, placeholder "description...", onInput (\v -> toMsg (Update (updateDescription v config))) ] []
        , div [ class "create-todo-item-modal__controls" ]
            [ button [ class "btn", id "create-todo-item-modal__create-btn", onClick (toMsg (Submit (close config))) ] [ text "Create" ]
            , button [ class "btn", id "create-todo-item-modal__cancel-btn", onClick (toMsg (Update (close config))) ] [ text "Cancel" ]
            ]
        ]


empty : Config
empty =
    { open = False
    , title = ""
    , description = ""
    }


open : Config -> Config
open modal =
    { modal | open = True }


close : Config -> Config
close modal =
    { modal | open = False }


updateTitle : String -> Config -> Config
updateTitle title modal =
    { modal | title = title }


updateDescription : String -> Config -> Config
updateDescription description modal =
    { modal | description = description }
