module SchedulePage where

import People
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)
import String exposing (isEmpty)
import Json.Encode as JSE
import Json.Decode as JSD
import Date

import Debug


-- UTILS
-- TODO: share with peoplePage

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))

-- MODEL

type Filling = Filled String
             | Unavailable
             | Available

type alias Massage = { num : Int , tim : String , nam : Filling }

type Slot = MassageCtor Massage
          | Break
          | Lunch


type alias Model =
    { slots : List Slot
    , dateToday : String
    , published : Bool
    , editingSlotNum : Int
    , editingName : String
    , autocompleteOptions : List String
    , autocompleteFocus : Maybe Int
    , possibleNames : List String
    , dateInput : Maybe String
    , editingDate : Bool
    , currentTime : Float
    , slotOpen : Bool }


nth : List a -> Int -> a -> a
nth xs n d =
  let
    maybeX = List.head (List.drop n xs)
  in
    case maybeX of
      Just x -> x
      Nothing -> d


nthMassage : List People.Person -> Int -> Filling
nthMassage xs n =
  let
    maybePerson = (List.head ( List.drop n xs ))
  in
    case maybePerson of
      Just person -> Filled person.name
      Nothing -> Available


fillSlot' :  Slot -> (List People.Person, List Slot) -> (List People.Person, List Slot)
fillSlot' slot ((first :: rest), result) = -- TODO: 'as' list
  case slot of
    MassageCtor m -> case m.nam of
                         Available -> (rest, (MassageCtor { m | nam <- Filled first.name } :: result ))
                         _ -> ((first :: rest), slot :: result)
    _ -> ((first :: rest), slot :: result)

fillSlots : List Slot -> List People.Person -> List Slot
fillSlots slots allPeople =
  let
    availablePeople = List.filter (not << (containPerson slots)) allPeople
  in
    List.foldl fillSlot' (availablePeople,[]) slots
    |> snd
    |> List.reverse -- TODO: how to cdr on to tail of a list

toSlots : List People.Person -> List Slot
toSlots people =
  [ MassageCtor {num=1, tim="10.00-10.20", nam=nthMassage people 0}
  , MassageCtor {num=2, tim="10.20-10.40", nam=nthMassage people 1}
  , MassageCtor {num=3, tim="10.40-11.00", nam=nthMassage people 2}
  , Break
  , MassageCtor {num=4, tim="11.20-11.40", nam=nthMassage people 3}
  , MassageCtor {num=5, tim="11.40-12.00", nam=nthMassage people 4}
  , MassageCtor {num=6, tim="12.00-12.20", nam=nthMassage people 5}
  , Lunch
  , MassageCtor {num=7, tim="13.20-13.40", nam=nthMassage people 6}
  , MassageCtor {num=8, tim="13.40-14.00", nam=nthMassage people 7}
  , MassageCtor {num=9, tim="14.90-14.20", nam=nthMassage people 8}
  , Break
  , MassageCtor {num=10, tim="14.40-15.00", nam=nthMassage people 9}
  , MassageCtor {num=11, tim="15.00-15.20", nam=nthMassage people 10}
  , MassageCtor {num=12, tim="15.20-15.40", nam=nthMassage people 11}
  , MassageCtor {num=13, tim="15.40-16.00", nam=nthMassage people 12}
  ]


extractNames : List People.Person -> List String
extractNames people =
  List.map .name people


monthToString : Date.Month -> String
monthToString m =
  case m of
    Date.Jan -> "1"
    Date.Feb -> "2"
    Date.Mar -> "3"
    Date.Apr -> "4"
    Date.May -> "5"
    Date.Jun -> "6"
    Date.Jul -> "7"
    Date.Aug -> "8"
    Date.Sep -> "9"
    Date.Oct -> "10"
    Date.Nov -> "11"
    Date.Dec -> "12"


nextMonday : Float -> String
nextMonday t =
  let
    ft = Date.fromTime t
    dow = Date.dayOfWeek ft
    nt =
        (case dow of
          Date.Mon -> t
          Date.Tue -> t + (6 * 24 * 60 * 60 *1000.0)
          Date.Wed -> t + (5 * 24 * 60 * 60 *1000.0)
          Date.Thu -> t + (4 * 24 * 60 * 60 *1000.0)
          Date.Fri -> t + (3 * 24 * 60 * 60 *1000.0)
          Date.Sat -> t + (2 * 24 * 60 * 60 *1000.0)
          Date.Sun -> t + (1 * 24 * 60 * 60 *1000.0))
        |> Date.fromTime
    in
      (toString (Date.day nt)) ++ "/" ++ (monthToString (Date.month nt)) ++ "/" ++  (toString (Date.year nt))


init : List People.Person -> (Model, Effects Action)
init people =
    ({slots = [ MassageCtor {num=1, tim="10.00-10.20", nam=Available}
              , MassageCtor {num=2, tim="10.20-10.40", nam=Available}
              , MassageCtor {num=3, tim="10.40-11.00", nam=Available}
              , Break
              , MassageCtor {num=4, tim="11.20-11.40", nam=Available}
              , MassageCtor {num=5, tim="11.40-12.00", nam=Available}
              , MassageCtor {num=6, tim="12.00-12.20", nam=Available}
              , Lunch
              , MassageCtor {num=7, tim="13.20-13.40", nam=Available}
              , MassageCtor {num=8, tim="13.40-14.00", nam=Available}
              , MassageCtor {num=9, tim="14.90-14.20", nam=Available}
              , Break
              , MassageCtor {num=10, tim="14.40-15.00", nam=Available}
              , MassageCtor {num=11, tim="15.00-15.20", nam=Available}
              , MassageCtor {num=12, tim="15.20-15.40", nam=Available}
              , MassageCtor {num=13, tim="15.40-16.00", nam=Available}
              ]
      , dateToday = ""
      , published = False
      , editingSlotNum = -1
      , editingName = ""
      , autocompleteOptions = []
      , autocompleteFocus = Nothing
      , possibleNames = extractNames people
      , dateInput = Nothing
      , editingDate = False
      , currentTime = 0.0
      , slotOpen = False }
    , Effects.none
    )


slotIsEmpty slot =
  case slot of
    MassageCtor m -> case m.nam of
                       Available -> True
                       _ -> False
    _ -> False


allSlotsFilled model =
  let numEmptySlots = List.length (List.filter slotIsEmpty model.slots) in
    numEmptySlots == 0


-- UPDATE

type Action
    = NoOp
    | Publish
    | Fill
    | GotFill (Maybe (List People.Person))
    | UpdateSlotInput Int String
    | EditSlot Int
    | StopEditing
    | CeaseEditing
    | ClearSlot Int
    | AutoCompleteSelected Int String
    | GotPeople (Maybe (List People.Person))
    | PersonDeleted (Result String People.Person)
    | UpdateDateInput String
    | EditDate Bool
    | OnPublish (Result String String)
    | TimeIsPassing Float
    | KeyPressed Int


slotHasNum : Int -> Slot -> Bool
slotHasNum num s =
  case s of
    MassageCtor m -> m.num == num
    _ -> False


nameFromSlot : List Slot -> Int -> String
nameFromSlot slots num =
  let
    slot = findSlot slots num
  in
    case slot of
      Just s -> case s of
                 MassageCtor m -> case m.nam of
                                    Filled n -> n
                                    Available -> ""
                                    Unavailable -> "xxx"
                 Lunch -> ""
                 Break -> ""
      Nothing -> ""


findSlot : List Slot -> Int -> Maybe Slot
findSlot slots num =
  List.head (List.filter (slotHasNum num) slots)


clearSlot : List Slot -> Int  -> List Slot
clearSlot slots num =
  let
    updateSlot s =
      case s of
        MassageCtor m -> if m.num == num then (MassageCtor { m | nam <- Available }) else s
        Lunch -> s
        Break -> s
  in
    List.map updateSlot slots


nameToSlot : List Slot -> Int -> String -> List Slot
nameToSlot slots num name =
  let
    updateSlot s =
      case s of
        MassageCtor m -> if m.num == num then (MassageCtor { m | nam <- Filled name }) else
                         if m.nam == Filled name then (MassageCtor { m | nam <- Available }) else s
        Lunch -> s
        Break -> s
  in
    List.map updateSlot slots


removeName : List Slot -> String -> List Slot
removeName slots name =
  let
    updateSlot s =
      case s of
        MassageCtor m -> if m.nam == Filled name then (MassageCtor { m | nam <- Available }) else s
        Lunch -> s
        Break -> s
  in
    List.map updateSlot slots

containsPerson : People.Person -> Slot -> Bool
containsPerson person slot =
  case slot of
    MassageCtor m -> case m.nam of
                       Filled nam -> nam == person.name
                       _ -> False
    _ -> False

containPerson : List Slot -> People.Person -> Bool
containPerson slots person =
  List.filter (containsPerson person) slots
  |> List.isEmpty
  |> not

getAutocompleteOptions : Model -> String -> List String
getAutocompleteOptions model name =
  if String.length name > 1 then
    List.filter (\n -> String.contains (String.toLower name) (String.toLower n)) model.possibleNames
  else
    []


is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"


onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
  on "keydown"
    (JSD.customDecoder keyCode is13)
    (\_ -> Signal.message address value)


validateDate : String -> Maybe String -> Maybe String
validateDate newDate currentDate =
  -- TODO: parse, or use regex
  Just newDate


validateName : String -> List String -> Maybe String
validateName name names =
  let
    lcName = String.toLower name
    validNames = List.filter (\n -> (String.toLower n) == lcName) names
  in
    if 1 == List.length validNames then
      List.head validNames
    else
      Nothing


fillSlot : Model -> String -> List Slot
fillSlot model name =
  let
    validation = validateName name model.autocompleteOptions
  in
    case (validation, model.editingSlotNum) of
      (Just name, num) ->
        nameToSlot model.slots num name
      _ ->
        model.slots


autocompleteDown : Model -> Model
autocompleteDown model =
  let
    max = List.length model.autocompleteOptions - 1
    maybeNum = model.autocompleteFocus
    newNum = case maybeNum of
      Just num -> if num < max then num + 1 else num
      Nothing -> 0
  in
    {model | autocompleteFocus <- Just newNum}

autocompleteUp : Model -> Model
autocompleteUp model =
  let
    max = List.length model.autocompleteOptions - 1
    maybeNum = model.autocompleteFocus
    newNum = case maybeNum of
      Just num -> if num > 0 then num - 1 else num
      Nothing -> max
  in
    {model | autocompleteFocus <- Just newNum}

update : Action -> Model -> (Model, Effects Action, Maybe String)
update action model =
  case (Debug.log "action" action) of
    NoOp -> (model, Effects.none, Nothing)
    Publish -> (model, publish model, Nothing)
    OnPublish publishResult -> ({ model | published <- True}, Effects.none, Nothing)
    Fill -> (model, getFill, Nothing)
    GotFill maybePeople ->
      let
        serverPeople = (Maybe.withDefault [People.Person "EX: maybe : elsewhere saw can't reach server?" "?"] maybePeople)
      in
        ( {model | slots <- fillSlots model.slots serverPeople}
        , Effects.none
        , Nothing
        )
    UpdateSlotInput num name -> ({ model | editingName <- name, autocompleteOptions <- getAutocompleteOptions model name}, Effects.none, Nothing)

    EditSlot num ->
      let editingName = nameFromSlot model.slots num in
        ({ model | slotOpen <- True, editingSlotNum <- num, editingName <- editingName, autocompleteFocus <- Nothing, autocompleteOptions <- getAutocompleteOptions model editingName}, Effects.none, Just ("#slot-" ++ toString num))

    StopEditing ->
      -- copy name from input box to slot
      let
        slots = fillSlot model model.editingName
      in
        ({ model | slots <- slots, slotOpen <- False}, Effects.task (Task.succeed CeaseEditing), Nothing)

    CeaseEditing ->
      ({ model | editingSlotNum <- -1 }, Effects.none, Nothing)

    ClearSlot num -> ({ model | slots <- clearSlot model.slots num}, Effects.none, Nothing)

    AutoCompleteSelected num name ->
      let
        slots = nameToSlot model.slots num name
      in
        ({model | autocompleteOptions <- [], editingName <- name, slots <- slots, slotOpen <- False}, Effects.none, Nothing)

    GotPeople maybePeople ->
      let
        serverPeople = (Maybe.withDefault [People.Person "EX: maybe : elsewhere saw can't reach server?" "?"] maybePeople)
      in
        ( {model | possibleNames <- extractNames serverPeople}
        , Effects.none
        , Nothing
        )

    PersonDeleted deletedPersonResult ->
      case deletedPersonResult of
        Ok deletedPerson ->
          let
            slotsLessName = removeName model.slots deletedPerson.name
            possibleNamesLessName = List.filter (\p -> p /= deletedPerson.name) model.possibleNames
          in
            ({ model | slots <- slotsLessName, possibleNames <- possibleNamesLessName }, Effects.none, Nothing )
        Err msg -> (model, Effects.none, Nothing  ) -- TODO: Report error somewhere

    UpdateDateInput currentDate ->
      let newDate = validateDate currentDate model.dateInput in
        ({ model | dateInput <- newDate }, Effects.none, Nothing)

    EditDate editing -> ({ model | editingDate <- Debug.log "editing is" editing}, Effects.none, if editing then Just "#date-0" else Nothing)

    TimeIsPassing a -> ({ model | currentTime <- a
                                , dateInput <- case model.dateInput of
                                                 Just d -> Just d
                                                 Nothing -> Just (nextMonday a)}
                        , Effects.none
                        , Nothing)

    KeyPressed k -> if
                      k == 27
                    then
                      ({ model | editingDate <- False, slotOpen <- False}, Effects.none, Nothing)
                    else
                      let
                        autocompleteActive = (List.length model.autocompleteOptions > 0)
                      in
                        if
                          k == 13 && autocompleteActive
                        then
                          case model.autocompleteFocus of
                            Just num ->
                              let
                                name = nth model.autocompleteOptions num ""
                              in
                                update (AutoCompleteSelected model.editingSlotNum name) model
                            Nothing -> (model, Effects.none, Nothing)
                        else
                          if
                            k == 38 && autocompleteActive -- u
                          then
                            (autocompleteUp model, Effects.none, Nothing)
                          else
                            if
                              k == 40 && autocompleteActive -- d
                            then
                              (autocompleteDown model, Effects.none, Nothing)
                            else
                              (model, Effects.none, Nothing)

-- VIEW

renderAutocompleteOption : Signal.Address Action -> Int -> Maybe Int -> Int -> String -> Html
renderAutocompleteOption address num focus i c =
  if focus == Just i then
    li [ class "focussed"
       , onClick address (AutoCompleteSelected num c) ] [ text c ]
  else
    li [ onClick address (AutoCompleteSelected num c) ] [ text c ] -- TODO: DRY

renderAutocompleteBox : Signal.Address Action -> Int -> Model -> Html
renderAutocompleteBox address num model =
  if(List.length model.autocompleteOptions > 0) then
     ul [ class "dropdown-menu" ]
         (List.indexedMap (renderAutocompleteOption address num model.autocompleteFocus) model.autocompleteOptions)
  else
    text ""

renderMassageEditBox : Signal.Address Action -> Model -> Massage -> List Html
renderMassageEditBox address model m =
    if model.slotOpen && model.editingSlotNum == m.num then
      [span [ class "edit-name" ] [
          input [ type' "text" --'
          , id ("slot-" ++ toString m.num)
          , placeholder "Enter name"
          , value model.editingName
          , name ("newSlotName" ++ (toString m.num)) -- TODO: is this needed?
          , on "input" targetValue (\v -> Signal.message address (UpdateSlotInput m.num v))
          , onBlur address StopEditing
          , onEnter address StopEditing
          ]
          [ ]
       ]
       , renderAutocompleteBox address m.num model
     ]
    else
      case m.nam of
        Available ->
          [ span [ class "name" ] [ text "" ] ]
        Unavailable ->
          [ span [ class "name" ] [ text "unavailable" ] ]
        Filled name ->
          [ span [ class "name" ] [ text name ]
          , button
            [ class "delete", onClick address (ClearSlot m.num) ]
            [ text "" ] ]


renderMassage : Signal.Address Action -> Model -> Massage -> Html
renderMassage address model m =
  li
    ([ class "slots"] ++ if model.editingSlotNum /= m.num then [(onClick address (EditSlot m.num))] else [])
    ([ span [ class "number" ] [ text ( (toString m.num) ++ " " ) ]
    , span [ class "time" ] [ text ( m.tim ++ " " ) ]
    ] ++ (renderMassageEditBox address model m))



renderSlot : Signal.Address Action -> Model -> Slot -> Html
renderSlot address model slot =
  case slot of
    MassageCtor m ->
      renderMassage address model m
    Break ->
      li [ class "full-row" ] [ span [ ] [ text "Break" ] ]
    Lunch ->
      li [ class "full-row" ] [ span [ ] [ text "Lunch" ] ]


renderSlots : Signal.Address Action -> Model -> Html
renderSlots address model =
  let
    items = List.map (renderSlot address model) model.slots
  in
    ul [ class "list" ] items


renderPublishButton address model =
  if allSlotsFilled model then
    button
      [ class "publish"
      , onClick address Publish ]
      [ text (if model.published then "Re-Publish!" else "Publish!") ]
  else
    button
      [ class "publish"
      , disabled True
      , onClick address Publish ]
      [ text (if model.published then "Re-Publish!" else "Publish!") ]


view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
      [ h1 [ ] [ text "Massage Schedule" ]
      , if model.editingDate then
          div [ ]
          [
            input
                [ type' "text" --'
                , placeholder "YYYY-MM-DD"
                , value (Maybe.withDefault "" model.dateInput)
                , name "newDate"
                , autofocus True
                , onInput address UpdateDateInput
                , onBlur address (EditDate False)
                , onEnter address (EditDate False)
                , class "date"
                , id "date-0"
                ]
                [ ]
            ]
        else
          h2 [ class "date", onClick address (EditDate True) ] [ text (Maybe.withDefault "" model.dateInput) ]
      , div [ ]
          [ button [ class "fill", onClick address Fill ] [ text "Auto Fill" ]
          , renderPublishButton address model
          ]
      , renderSlots address model
      ]

-- EFFECTS

getFill : Effects Action
getFill =
    Http.get People.peopleResponseDecoder ("http://localhost:3000/api/v1/fill")
    |> Task.toMaybe
    |> Task.map GotFill
    |> Effects.task

encodeSlot : List Slot -> Int -> JSE.Value
encodeSlot slots num =
  let slot = findSlot slots num in
    case slot of
      Just s -> case s of
                 MassageCtor m -> case m.nam of
                                    Filled n -> JSE.object [ ("type", JSE.string "massage"), ("name", JSE.string n), ("time", JSE.string m.tim), ("num", JSE.int m.num) ]
                                    Available -> JSE.object [ ("type", JSE.string "massage"),("name", JSE.string ""), ("time", JSE.string m.tim), ("num", JSE.int m.num) ]
                                    Unavailable -> JSE.object [ ("type", JSE.string "massage"),("name", JSE.null), ("time", JSE.string m.tim), ("num", JSE.int m.num) ]
                 Lunch -> JSE.object [ ("type", JSE.string "lunch") ]
                 Break -> JSE.object [ ("type", JSE.string "break") ]
      Nothing -> JSE.object [ ]

publish : Model -> Effects Action
publish model =
  Http.send Http.defaultSettings
      { verb = "POST"
      , headers = [("Content-Type", "application/json")]
      , url = "http://localhost:3000/api/v1/schedules"
      , body = Http.string (
                 JSE.encode 0 (
                   JSE.object [ ("date",JSE.string (Maybe.withDefault "" model.dateInput))
                              , ("slots", (JSE.list [ (encodeSlot model.slots 1)
                                                    , (encodeSlot model.slots 2)
                                                    , (encodeSlot model.slots 3)
                                                    , (encodeSlot model.slots 4)
                                                    , (encodeSlot model.slots 5)
                                                    , (encodeSlot model.slots 6)
                                                    , (encodeSlot model.slots 7)
                                                    , (encodeSlot model.slots 8)
                                                    , (encodeSlot model.slots 9)
                                                    , (encodeSlot model.slots 10)
                                                    , (encodeSlot model.slots 11)
                                                    , (encodeSlot model.slots 12)
                                                    , (encodeSlot model.slots 13)])) ]))
      }
    |> Task.toMaybe
    |> Task.map publishResponseDecoder
    |> Task.map OnPublish
    |> Effects.task

publishResponseDecoder : Maybe Http.Response -> Result String String
publishResponseDecoder response =
  case response of
    Nothing -> Err "No publish response from server"
    Just r ->
      case r.value of
        Http.Text t -> Ok t
        Http.Blob _ -> Err "EX: Publish decoder can't handle blob"
