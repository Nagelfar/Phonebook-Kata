# Implementation of the Phonebook Kata

An implementation of the Phonebook-Kata from [Ayende](https://twitter.com/ayende/status/1369988712206110723?s=20) in Elm.

Requirements of the Kata:

    Build a program that supports multiple phone books
    Access & store them via a dedicated file parameter
    Support two primary access methods:
        - Adding one entry to the phone book
          An entry consists of a name and a phone number
        - Return a list of lexical sorted entries from the phone book
          Support skip & limit parameters

The Kata implementation started in the Salzburg Software Craftmanship Meetup Group with the following rules:

- Write the phone book with immutable data structures
- Mutate the state at the last responsible moment


## Examples 1

Input:

    pb foo.txt add Adam +987654
    pb foo.txt add Christian +4312345
    pb foo.txt list

Output:     

    Adam   +987654
    Christian  +4312345

## Example 2

Input: 

    pb bar.txt add Markus +12334
    pb bar.txt add Christian +4312345
    pb bar.txt add Adam +987654
    pb bar.txt list 1

Output:

    > Christian  +4312345
    > Markus +12334

## Run the example

- Install Elm from <http://elm-lang.org/>
- Install Node.js <http://nodejs.org/>
- Install dependencies with `npm i`
- Build the application `npm run build`
- Make sure `pb` is executable via `chmod +x ./cli/pb`
- Run the phonebook via `./cli/pb <arguments>`