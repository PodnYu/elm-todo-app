module TodoItem.Api exposing (..)

import Http
import Json.Decode as D
import Json.Encode as E
import TodoItem.TodoItem as TI


todosApiBaseUrl : String
todosApiBaseUrl =
    "http://localhost:3000/api/v1/todos/"


type alias CreateTodoItemDto =
    { title : String
    , description : String
    }


getTodoItems : (Result Http.Error (List TI.TodoItem) -> msg) -> Cmd msg
getTodoItems msg =
    Http.get
        { url = todosApiBaseUrl
        , expect = Http.expectJson msg todoItemsDecoder
        }


createTodoItem : CreateTodoItemDto -> (Result Http.Error TI.TodoItem -> msg) -> Cmd msg
createTodoItem newItem msg =
    Http.post
        { url = todosApiBaseUrl
        , body = Http.jsonBody (todoItemCreateDtoEncoder newItem)
        , expect = Http.expectJson msg todoItemDecoder
        }


updateTodoItemChecked : String -> Bool -> (String -> Bool -> Result Http.Error () -> msg) -> Cmd msg
updateTodoItemChecked id checked msg =
    Http.post
        { url =
            todosApiBaseUrl
                ++ id
                ++ ":"
                ++ (if checked then
                        ""

                    else
                        "un"
                   )
                ++ "check"
        , body = Http.emptyBody
        , expect = Http.expectWhatever (msg id checked)
        }


deleteTodoItem : String -> (String -> Result Http.Error () -> msg) -> Cmd msg
deleteTodoItem id msg =
    Http.request
        { url = todosApiBaseUrl ++ id
        , method = "DELETE"
        , headers = []
        , tracker = Nothing
        , timeout = Nothing
        , body = Http.emptyBody
        , expect = Http.expectWhatever (msg id)
        }


todoItemCreateDtoEncoder : CreateTodoItemDto -> E.Value
todoItemCreateDtoEncoder item =
    E.object
        [ ( "title", E.string item.title )
        , ( "description", E.string item.description )
        ]


todoItemDecoder : D.Decoder TI.TodoItem
todoItemDecoder =
    D.map4 TI.TodoItem
        (D.field "id" D.string)
        (D.field "title" D.string)
        (D.field "description" D.string)
        (D.field "checked" D.bool)


todoItemsDecoder : D.Decoder (List TI.TodoItem)
todoItemsDecoder =
    D.list todoItemDecoder
