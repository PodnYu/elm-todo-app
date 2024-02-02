module TodoItem.TodoList exposing (..)

import List
import TodoItem.TodoItem as TI


type alias TodoList =
    List TI.TodoItem


empty : TodoList
empty =
    []


map : (TI.TodoItem -> a) -> TodoList -> List a
map f l =
    List.map f l


push : TodoList -> TI.TodoItem -> TodoList
push l i =
    List.append l [ i ]


updateChecked : TodoList -> String -> Bool -> TodoList
updateChecked l id checked =
    List.map
        (\item ->
            if item.id == id then
                { item | checked = checked }

            else
                item
        )
        l


deleteItem : TodoList -> String -> TodoList
deleteItem l id =
    List.filter (\item -> item.id /= id) l
