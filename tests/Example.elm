module Example exposing (..)

import Code exposing (..)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)



-- Build a program that supports multiple phone booksAccess & store them via a dedicated file parameter
-- Support two primary access methods:
-- Adding one entry to the phone book
-- An entry consists of a name and a phone number
-- Return a list of lexical sorted entries from the phone bookSupport skip & limit parameters
-- Rules:
-- Write the phone book with immutable data structures
-- Mutate the state at the last responsible moment
-- Examples:
-- pb foo.txt add Adam +987654
-- pb foo.txt add Christian +4312345
-- pb foo.txt list
-- > Adam   +987654
-- > Christian  +4312345
-- pb bar.txt add Markus +12334
-- pb bar.txt add Christian +4312345
-- pb bar.txt add Adam +987654
-- pb bar.txt list 1
-- > Christian  +4312345
-- > Markus +12334


applyToPhonebook : String -> PhoneBookResult -> PhoneBookResult
applyToPhonebook arguments bookResult =
    case bookResult of
        Added book ->
            case arguments |> parsePhonebookArguments of
                Ok operation ->
                    phonebook operation book

                Err e ->
                    Debug.todo e

        Listed _ ->
            Debug.todo "Unexpected result"


suite : Test
suite =
    describe "Example 1"
        [ describe "guiding tests"
            [ test "Add Adam and Christian leads to a sorted output" <|
                \_ ->
                    let
                        -- arrange
                        book =
                            []
                                |> Added
                                |> applyToPhonebook "add Adam +987654"
                                |> applyToPhonebook "add Christian +4312345"

                        expected =
                            Listed "Adam\t+987654\nChristian\t+4312345"
                    in
                    -- act
                    book
                        |> applyToPhonebook "list"
                        -- assert
                        |> Expect.equal expected
            , test "Add Christian and Adam leads to a sorted output" <|
                \_ ->
                    let
                        -- arrange
                        book =
                            []
                                |> Added
                                |> applyToPhonebook "add Christian +4312345"
                                |> applyToPhonebook "add Adam +987654"

                        expected =
                            Listed "Adam\t+987654\nChristian\t+4312345"
                    in
                    -- act
                    book
                        |> applyToPhonebook "list"
                        -- assert
                        |> Expect.equal expected
            ]
        , test "parsing add with the right arguments" <|
            \_ ->
                let
                    result =
                        parsePhonebookArguments "add Adam +987654"
                in
                result |> Expect.equal (Ok <| ShouldAdd "Adam" "+987654")
        , test "parsing list with the right arguments" <|
            \_ ->
                let
                    result =
                        parsePhonebookArguments "list"
                in
                result |> Expect.equal (Ok <| ShouldList Nothing)
        ]
