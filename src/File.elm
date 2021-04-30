port module File exposing (Event(..), SaveFile, save, load, subscriptions)


port load : String -> Cmd msg


port onFileLoaded : (String -> msg) -> Sub msg


type alias SaveFile =
    { fileName : String
    , content : String
    }


port save : SaveFile -> Cmd msg


type Event
    = FileLoaded String


subscriptions : Sub Event
subscriptions =
    onFileLoaded FileLoaded
