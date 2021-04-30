module Main exposing (..)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import File
import Ports

import elm.Code exposing (..)

type Msg
    = NoOp
    | File File.Event


type alias CliOptions =
    { arguments : List String
    }


type alias Flags =
    Program.FlagsIncludingArgv {}



writePhonebookToFile : String -> Phonebook -> Cmd Msg
writePhonebookToFile filename book =
    File.save
        { fileName = filename
        , content = book |> listItems Nothing
        }


program : Program.Config CliOptions
program =
    Program.config
        |> Program.add
            (OptionsParser.build CliOptions
                -- |> with (Option.requiredPositionalArg "arguments")
                |> OptionsParser.withRestArgs (Option.restArgs "rest")
            )


update : CliOptions -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        File (File.FileLoaded content) ->
            let
                phonebookContent =
                    content
                        |> parsePhonebookFromContent
            in
            ( model
            , case phonebookContent |> Result.map (phonebook model.operation) of
                Ok (Added newPhoneBook) ->
                    writePhonebookToFile model.fileName newPhoneBook

                Ok (Listed items) ->
                    Ports.printAndExitSuccess items

                Err e ->
                    Ports.printAndExitFailure e
            )


init : Flags -> CliOptions -> ( Model, Cmd Msg )
init flags { arguments } =
    case arguments |> String.join " " |> parseModel of
        Ok model ->
            ( model
            , File.load model.fileName
            )

        Err e ->
            ( { fileName = e
              , operation = ShouldList Nothing
              }
            , Ports.printAndExitFailure e
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    File.subscriptions |> Sub.map File


main : Program.StatefulProgram Model Msg CliOptions {}
main =
    Program.stateful
        { printAndExitFailure = Ports.printAndExitFailure
        , printAndExitSuccess = Ports.printAndExitSuccess
        , init = init
        , config = program
        , subscriptions = subscriptions
        , update = update
        }
