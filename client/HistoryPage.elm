module HistoryPage where

import People
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)
import Http
import Json.Decode as JSD exposing ((:=))
import Json.Encode as JSE
import Task exposing (..)
import String exposing (toUpper, repeat, trimRight)

-- UTILS
-- TODO: share with schedulepage


onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))


-- MODEL


type alias Model =
    { people : List People.Person
    }


init : (Model, Effects Action)
init =
    ({ people = []}
    , Effects.none
    )


-- UPDATE


type Action
    = NoOp
    | GotPeople (Maybe (List People.Person))


sortPeople : List People.Person -> List People.Person
sortPeople people =
  let keyFn = (\person -> if (person.lastDate == "never") then "0000-00-00" else person.lastDate) in
    List.sortBy keyFn people -- TODO: Sort by name if dates are the same

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    GotPeople maybePeople ->
      let
        serverPeople =  sortPeople (Maybe.withDefault [People.Person "EX: maybe : saw can't reach server?" "?"] maybePeople)
      in
        ( {model | people <- serverPeople}
        , Effects.none
        )

    NoOp -> (model, Effects.none)




-- VIEW

renderPerson : Signal.Address Action -> People.Person -> Html
renderPerson address person =
  li
    [ class "person" ]
    [ span [ class "name" ] [ text person.name ]
    , span [ class "date" ] [ text person.lastDate ]
    ]


personList : Signal.Address Action -> List People.Person -> Html
personList address people =
  let
    items = List.map (renderPerson address) people
  in
    ul [ class "list" ] items


pageHeader : Html
pageHeader =
  h1 [ ] [ text "Recent schedules" ]


view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ pageHeader
    , personList address model.people
    ]

-- EFFECTS



jsonStringToPerson : String -> Result String People.Person
jsonStringToPerson t =
  (JSD.decodeString
    (JSD.object2
      People.personMaker
      (JSD.maybe ("name" := JSD.string))
      (JSD.maybe ("last-date" := JSD.string)))
    t)

personResponseDecoder : Maybe Http.Response -> Result String People.Person
personResponseDecoder response =
  case response of
    Nothing -> Err "No person response from server"
    Just r ->
      case r.value of
        Http.Text t -> jsonStringToPerson t
        Http.Blob _ -> Err "EX: Person decoder can't handle blob"
