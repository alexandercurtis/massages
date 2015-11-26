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

type alias Booking =
  { name : String
  , bookings : List Bool
  }

type alias Model =
    { recentDates : List String
    , bookings : List (String, List String)
    }


init : (Model, Effects Action)
init =
    ({ recentDates = []
    ,  bookings = []}
    , getBookings
    )


-- UPDATE


type Action
    = NoOp
    | GotBookings (Maybe (List String, (List (String, List String))))


sortPeople : List Booking -> List Booking
sortPeople people =
  let keyFn = (\person -> person.name) in
    List.sortBy keyFn people

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    GotBookings maybePeople ->
      let
        (dates,bookings) = (Maybe.withDefault ([], []) maybePeople)
      in
        ( {model | bookings = bookings, recentDates = dates}
        , Effects.none
        )

    NoOp -> (model, Effects.none)




-- VIEW

renderHeading : List String -> Html
renderHeading dates =
  let
    titles = List.map (\date -> span [ class "date-header" ] [ text date ]) dates
  in
    li [ class "booking" ] <| (span [class "booked-name" ] [ text "Name" ]) :: titles

row : List String -> (String, List String) -> Html
row dates (name,h) =
  let
    bookings = List.map (\a -> if
                                 List.member a h
                               then
                                 span [ class "booked" ] [ text "" ]
                               else
                                 span [ class "not-booked" ] [ text "" ])
                        dates
  in
    li [ class "booking" ] ([ span [ class "booked-name" ] [ text name ] ] ++ bookings)

personList : Signal.Address Action -> List String -> List (String, List String) -> Html
personList address dates bookings =
  let
    heading = renderHeading dates
    rows = List.map (row dates) bookings
  in
    ul [ class "list" ] (heading :: rows)


pageHeader : Html
pageHeader =
  h1 [ ] [ text "Recent schedules" ]


view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ pageHeader
    , personList address model.recentDates model.bookings
    ]

-- EFFECTS


bookingMaker : Maybe String -> Maybe (List String) -> (String, List String)
bookingMaker n d =
  ( (Maybe.withDefault "EX: missing name" n), (Maybe.withDefault [] d ))

wtfigo :  Maybe (List String) -> Maybe (List (String, List String)) -> (List String, List (String, List String))
wtfigo d h =
  ( (Maybe.withDefault ["EX: missing dates"] d), (Maybe.withDefault [] h))

bookingResponseDecoder : JSD.Decoder (List String, (List (String, List String)))
bookingResponseDecoder =
  let
    date =
      JSD.string
    person =
      JSD.object2
        bookingMaker
        (JSD.maybe ("name" := JSD.string))
        (JSD.maybe ("bookings" := (JSD.list JSD.string)))
  in
    JSD.object2 wtfigo (JSD.maybe ("dates" := (JSD.list date))) (JSD.maybe ("history" := (JSD.list person)))

getBookingsPlus : Task x (Maybe (List String, (List (String, List String))))
getBookingsPlus =
    Http.get bookingResponseDecoder ("http://localhost:3000/api/v1/history")
    |> Task.toMaybe

getBookings =
    getBookingsPlus
    |> Task.map GotBookings
    |> Effects.task
