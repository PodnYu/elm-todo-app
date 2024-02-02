module Main exposing (..)

import Browser
import Html exposing (Html, button, div, header, text)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)
import Http
import Process
import Task
import TodoItem.Api as TIApi
import TodoItem.CreateDialog as TICreateDialog exposing (close)
import TodoItem.TodoItem as TI
import TodoItem.TodoList as TL


type alias Model =
    { todoItems : TL.TodoList
    , createTodoItemDialogConfig : TICreateDialog.Config
    , err : Maybe String
    }


type Msg
    = UpdateModal TICreateDialog.Msg
    | UpdateTodoItemChecked String Bool
    | DeleteTodoItem String
    | GotTodoItems (Result Http.Error TL.TodoList)
    | TodoItemCreated (Result Http.Error TI.TodoItem)
    | TodoItemCheckedUpdated String Bool (Result Http.Error ())
    | TodoItemDeleted String (Result Http.Error ())
    | ResetErr


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { todoItems = TL.empty
      , createTodoItemDialogConfig = TICreateDialog.empty
      , err = Nothing
      }
    , TIApi.getTodoItems GotTodoItems
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResetErr ->
            ( { model | err = Nothing }, Cmd.none )

        UpdateModal modalMsg ->
            case modalMsg of
                TICreateDialog.Update new ->
                    ( { model | createTodoItemDialogConfig = new }, Cmd.none )

                TICreateDialog.Submit new ->
                    ( { model | createTodoItemDialogConfig = new }
                    , TIApi.createTodoItem (toCreateTodoItemDto new) TodoItemCreated
                    )

                TICreateDialog.ClickAway ->
                    ( { model | createTodoItemDialogConfig = close model.createTodoItemDialogConfig }, Cmd.none )

                TICreateDialog.NoOp ->
                    ( model, Cmd.none )

        GotTodoItems result ->
            case result of
                Ok todoItems ->
                    ( { model | todoItems = todoItems }, Cmd.none )

                Err e ->
                    handleHttpErr e { model | todoItems = TL.empty }

        UpdateTodoItemChecked id checked ->
            ( model, TIApi.updateTodoItemChecked id checked TodoItemCheckedUpdated )

        DeleteTodoItem id ->
            ( model, TIApi.deleteTodoItem id TodoItemDeleted )

        TodoItemCreated result ->
            case result of
                Ok created ->
                    ( { model
                        | todoItems = TL.push model.todoItems created
                        , createTodoItemDialogConfig = TICreateDialog.empty
                      }
                    , Cmd.none
                    )

                Err e ->
                    handleHttpErr e model

        TodoItemCheckedUpdated id checked result ->
            case result of
                Ok _ ->
                    ( { model
                        | todoItems = TL.updateChecked model.todoItems id checked
                      }
                    , Cmd.none
                    )

                Err e ->
                    handleHttpErr e model

        TodoItemDeleted id result ->
            case result of
                Ok _ ->
                    ( { model | todoItems = TL.deleteItem model.todoItems id }, Cmd.none )

                Err e ->
                    handleHttpErr e model


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ header [ id "header" ] [ text "TODO App" ]
        , viewError model.err
        , viewCreateTodoItemBtn model.createTodoItemDialogConfig
        , viewTodoItems model.todoItems
        , TICreateDialog.view model.createTodoItemDialogConfig UpdateModal
        ]


errFromMaybe : Maybe String -> String
errFromMaybe e =
    case e of
        Just str ->
            str

        Nothing ->
            "no error"


viewError : Maybe String -> Html Msg
viewError e =
    case e of
        Just msg ->
            div
                [ class "error" ]
                [ text msg ]

        Nothing ->
            Html.text ""


viewCreateTodoItemBtn : TICreateDialog.Config -> Html Msg
viewCreateTodoItemBtn config =
    div []
        [ button
            [ class "create-todo-item-btn"
            , class "btn"
            , onClick (UpdateModal (TICreateDialog.Update (TICreateDialog.open config)))
            ]
            [ text "Create TODO item" ]
        ]


viewTodoItems : TL.TodoList -> Html Msg
viewTodoItems items =
    div [ class "todo-list" ]
        (TL.map (\item -> viewTodoItem item) items)


viewTodoItem : TI.TodoItem -> Html Msg
viewTodoItem item =
    div
        [ classList
            [ ( "todo-item", True )
            , ( "todo-item_checked", item.checked )
            ]
        ]
        [ div [ class "todo-item__text" ] [ text item.title ]
        , div [ class "todo-item__controls" ]
            [ button [ id "check-todo-item-btn", class "btn", onClick (UpdateTodoItemChecked item.id (not item.checked)) ] [ text "Check" ]
            , button [ id "delete-todo-item-btn", class "btn", onClick (DeleteTodoItem item.id) ] [ text "Delete" ]
            ]
        ]


handleHttpErr : Http.Error -> Model -> ( Model, Cmd Msg )
handleHttpErr e model =
    ( { model | err = Just (httpErrorToString e) }
    , Process.sleep 3000 |> Task.perform (\_ -> ResetErr)
    )


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Bad url: " ++ url

        Http.Timeout ->
            "Timeout error"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus 500 ->
            "Internal server error: 500"

        Http.BadStatus 400 ->
            "Bad request: 400"

        Http.BadStatus s ->
            "Unknown error " ++ String.fromInt s

        Http.BadBody msg ->
            "Bad body: " ++ msg


toCreateTodoItemDto : TICreateDialog.Config -> TIApi.CreateTodoItemDto
toCreateTodoItemDto { title, description } =
    { title = title, description = description }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
