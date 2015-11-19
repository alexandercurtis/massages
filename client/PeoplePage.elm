module PeoplePage where

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
    , visiblePeople : List People.Person
    , nameInput : String
    }


init : List String -> (Model, Effects Action)
init _ =
    ({ people = []
     , visiblePeople = []
     , nameInput = ""}
    , Effects.none
    )


-- UPDATE


type Action
    = NoOp
    | UpdateNameInput String
    | Delete String
    | PersonDeleted (Result String People.Person)
    | Add
    | OnPersonAdded (Result String People.Person)
    | GotPeople (Maybe (List People.Person))

filterVisiblePeople : String -> List People.Person -> List People.Person
filterVisiblePeople name people =
  List.filter (\person -> String.contains (String.toLower name) (String.toLower person.name)) people

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
        ( {model | people <- serverPeople, visiblePeople <- filterVisiblePeople model.nameInput serverPeople}
        , Effects.none
        )
    Delete name ->
      ( model
      , markDeleted name)

    PersonDeleted deletedPersonResult ->
      case deletedPersonResult of
        Ok deletedPerson ->
          let
            remainingPeople =
              List.filter (\person -> person.name /= deletedPerson.name) model.people
            remainingVisiblePeople =
              List.filter (\person -> person.name /= deletedPerson.name) model.visiblePeople
          in
            ({ model | people <- remainingPeople, visiblePeople <- remainingVisiblePeople }, Effects.none )
        Err msg -> (model, Effects.none) -- TODO: Report error somewhere

    UpdateNameInput currentName ->
      let
        remainingVisiblePeople =
          filterVisiblePeople currentName model.people
      in
        ({ model | nameInput <- currentName, visiblePeople <- remainingVisiblePeople }, Effects.none)

    Add ->
      let
        nameToAdd = model.nameInput
        isInvalid model = String.isEmpty model.nameInput
      in
        if isInvalid model
        then (model, Effects.none)
        else
          ( model
          , submitPerson nameToAdd)

    OnPersonAdded newPersonResult ->
      case newPersonResult of
        Ok newPerson ->
          let
            people = sortPeople (newPerson :: model.people)
          in
          ({ model | nameInput <- ""
                   , people <- people
                   , visiblePeople <- people
               }
               , Effects.none)
        Err msg -> (model, Effects.none) -- TODO: Report error somewhere

    NoOp -> (model, Effects.none)




-- VIEW

renderPerson : Signal.Address Action -> People.Person -> Html
renderPerson address person =
  li
    [ class "person" ]
    [ span [ class "name" ] [ text person.name ],
      span [ class "date" ] [ text person.lastDate ],
      button
        [ class "delete", onClick address (Delete person.name) ]
        [ text "" ]
    ]


personList : Signal.Address Action -> List People.Person -> Html
personList address people =
  let
    items = List.map (renderPerson address) people
  in
    ul [ class "list" ] items


personForm : Signal.Address Action -> Model -> Html
personForm address model =
  div [ ]
    [ input
        [ type' "text", --'
          placeholder "New person's name",
          value model.nameInput,
          name "newName",
          autofocus True,
          onInput address UpdateNameInput
        ]
        [ ],
      button [ class "add", onClick address Add ] [ text "Add" ]
    ]


pageHeader : Html
pageHeader =
  h1 [ ] [ text "People wanting massages" ]


view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ pageHeader
    , personForm address model
    , personList address model.visiblePeople
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



-- markDeleted : String -> Effects Action
markDeleted name =
  Http.send Http.defaultSettings
      { verb = "PUT"
      , headers = [("Content-Type", "application/json")]
      , url = "http://localhost:3000/api/v1/people"
      , body = Http.string (JSE.encode 0 (JSE.object [ ("name", JSE.string name), ("deleted", JSE.bool True) ]))
      }
    |> Task.toMaybe
    |> Task.map personResponseDecoder
    |> Task.map PersonDeleted
    |> Effects.task



submitPerson : String -> Effects Action
submitPerson name =
  Http.send Http.defaultSettings
      { verb = "POST"
      , headers = [("Content-Type", "application/json")]
      , url = "http://localhost:3000/api/v1/people"
      , body = Http.string (JSE.encode 0 (JSE.object [ ("name", JSE.string name) ]))
      }
    |> Task.toMaybe
    |> Task.map personResponseDecoder
    |> Task.map OnPersonAdded
    |> Effects.task
