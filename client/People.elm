module People where

import Http
import Json.Decode as JSD exposing ((:=))
import Task exposing (..)
import Effects exposing (Effects, Never)

-- MODEL


type alias Person =
  { name: String,
    lastDate: String
  }

type Action = GotPeople (Maybe (List Person))

-- EFFECTS


personMaker : Maybe String -> Maybe String -> Person
personMaker n d =
  Person (Maybe.withDefault "EX: missing name" n) (Maybe.withDefault "EX: missing date" d )

peopleResponseDecoder : JSD.Decoder (List Person)
peopleResponseDecoder =
  let person =
        JSD.object2
          personMaker
          (JSD.maybe ("name" := JSD.string))
          (JSD.maybe ("last-date" := JSD.string))
  in
      JSD.list person


getPeople : Task x (Maybe (List Person))
getPeople =
    Http.get peopleResponseDecoder ("http://localhost:3000/api/v1/people")
    |> Task.toMaybe
