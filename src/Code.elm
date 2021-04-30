module Code exposing (..)

type alias Model =
    { fileName : String
    , operation : Operation
    }


type alias Number =
    Int


type alias Entry =
    { name : String
    , number : String
    }


type alias Phonebook =
    List Entry


type PhoneBookResult
    = Added Phonebook
    | Listed String


type Operation
    = ShouldAdd String String
    | ShouldList (Maybe Number)


asEntry : String -> Result String Entry
asEntry line =
    case line |> String.split "\t" of
        [ name, number ] ->
            Ok <|
                { name = name, number = number }

        e ->
            Err <|
                "Could not parse entry from: "
                    ++ String.join " " e


addToPhonebook : Phonebook -> Entry -> Phonebook
addToPhonebook book entry =
    entry :: book


listItems : Maybe Number -> Phonebook -> String
listItems count book =
    book
        |> List.sortBy (\item -> item.name)
        |> List.map (\item -> item.name ++ "\t" ++ item.number)
        |> List.take (count |> Maybe.withDefault (List.length book))
        |> String.join "\n"


phonebook : Operation -> Phonebook -> PhoneBookResult
phonebook operation book =
    case operation of
        ShouldAdd name number ->
            addToPhonebook book { name = name, number = number }
                |> Added

        ShouldList count ->
            book
                |> listItems count
                |> Listed


parsePhonebookArguments : String -> Result String Operation
parsePhonebookArguments arguments =
    case arguments |> String.split " " of
        [ "add", name, number ] ->
            ShouldAdd name number
                |> Ok

        [ "list" ] ->
            ShouldList Nothing
                |> Ok

        [ "list", number ] ->
            number
                |> String.toInt
                |> ShouldList
                |> Ok

        _ ->
            Err <| "Could not parse arguments " ++ arguments



parseFileParameters : String -> Result String ( String, String )
parseFileParameters arguments =
    case arguments |> String.split " " of
        fileName :: rest ->
            Ok ( fileName, rest |> String.join " " )

        _ ->
            Err <| "Could not parse filename from arguments: " ++ arguments


parseModel : String -> Result String Model
parseModel arguments =
    arguments
        |> parseFileParameters
        |> Result.andThen
            (\( fileName, remainingArguments ) ->
                remainingArguments
                    |> parsePhonebookArguments
                    |> Result.map
                        (\operation ->
                            { fileName = fileName
                            , operation = operation
                            }
                        )
            )


parsePhonebookFromContent : String -> Result String Phonebook
parsePhonebookFromContent file =
    file
        |> String.split "\n"
        |> List.filter (String.isEmpty >> not)
        |> List.map asEntry
        |> List.foldl
            (\item state ->
                case ( item, state ) of
                    ( Ok entry, Ok book ) ->
                        Ok <| addToPhonebook book entry

                    ( Ok _, Err errors ) ->
                        Err errors

                    ( Err e, Ok _ ) ->
                        Err [ e ]

                    ( Err e, Err errors ) ->
                        Err <| e :: errors
            )
            (Ok [])
        |> Result.mapError (String.join "\n")
