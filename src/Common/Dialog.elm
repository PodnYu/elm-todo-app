module Common.Dialog exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (custom, onClick)
import Json.Decode as Decode


type Msg
    = ClickAway
    | NoOp


type alias Config msg =
    { open : Bool
    , classList : List ( String, Bool )
    , onClickAway : msg
    , noOp : msg
    }


view : Config msg -> List (Html msg) -> Html msg
view config children =
    div
        [ classList [ ( "modal__backdrop", True ), ( "modal__backdrop_closed", not config.open ) ]
        , onClick config.onClickAway
        ]
        [ div
            [ class "modal__body"
            , classList config.classList
            , custom "click" (Decode.succeed { stopPropagation = True, preventDefault = True, message = config.noOp })
            ]
            children
        ]
