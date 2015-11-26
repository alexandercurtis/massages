module Container where

import People
import PrimaryNav
import SchedulePage
import PeoplePage
import HistoryPage

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)

import Task exposing (..)

import Time
import Keyboard
import Set

import Debug

-- MODEL


type alias Model =
    { primaryNav : PrimaryNav.Model
    , schedulePage : SchedulePage.Model
    , peoplePage : PeoplePage.Model
    , historyPage : HistoryPage.Model
    , activePage : String
    , focusAddress : Signal.Address String
    , massage : String
    }

timeSignal = Signal.map TimeIsPassing (Time.every Time.second)
keyboardSignal = Signal.map KeysDown (Keyboard.keysDown)
--keyboardSignal = Signal.map KeyPressed (Keyboard.presses)

init : Signal.Address String -> (Model, Effects Action)
init focusAddress =
    let (schedulePage,scheduleEffect) = SchedulePage.init []
        (peoplePage,peopleEffect) = PeoplePage.init ["Andy Atkins", "Anne Astwick", "Fred Bloggs", "Julie Smith", "Zak Zigzag"]
        (historyPage,historyEffect) = HistoryPage.init
    in
      ({ primaryNav = PrimaryNav.init ["Schedule", "History", "People"] "Schedule"
       , schedulePage = schedulePage
       , peoplePage = peoplePage
       , historyPage = historyPage
       , activePage = "Schedule"
       , focusAddress = focusAddress
       , massage = ""
       }
       , Effects.batch [ Effects.map DelegateToSchedulePage scheduleEffect
                       , Effects.map DelegateToPeoplePage peopleEffect
                       , Effects.map DelegateToHistoryPage historyEffect
                       , getPeople ] )


-- UPDATE


type Action
    = NoOp
    | NoOp1 ()
    | DelegateToPrimaryNav PrimaryNav.Action
    | DelegateToSchedulePage SchedulePage.Action
    | DelegateToPeoplePage PeoplePage.Action
    | DelegateToHistoryPage HistoryPage.Action
    | GotPeople (Maybe (List People.Person))
    | TimeIsPassing Float
--    | KeyPressed Int
    | KeysDown (Set.Set Int)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model,Effects.none)
    NoOp1 _ -> (model,Effects.none)
    DelegateToPrimaryNav primaryNavAction ->
      let (m,e) = PrimaryNav.update primaryNavAction model.primaryNav in
        ({ model | primaryNav = m, activePage = m.selected }, Effects.map DelegateToPrimaryNav e)
    DelegateToSchedulePage schedulePageAction ->
      let (m,e,f) = SchedulePage.update schedulePageAction model.schedulePage in
        ({ model | schedulePage = m }, Effects.batch [ Effects.map DelegateToSchedulePage e
                                                        , case f of
                                                            Nothing -> Effects.none
                                                            Just s -> Effects.map NoOp1 (Signal.send model.focusAddress s |> Effects.task) ])

    DelegateToPeoplePage peoplePageAction ->
      case peoplePageAction of
        PeoplePage.PersonDeleted personResult ->
          let (pm, pe) = PeoplePage.update peoplePageAction model.peoplePage
              (sm, se, sf) = SchedulePage.update (SchedulePage.PersonDeleted personResult) model.schedulePage
          in ({ model | peoplePage = pm, schedulePage = sm }, Effects.batch [ Effects.map DelegateToPeoplePage pe
                                                                              , Effects.map DelegateToSchedulePage se
                                                                              , case sf of
                                                                                  Nothing -> Effects.none
                                                                                  Just s -> Effects.map NoOp1 (Signal.send model.focusAddress s |> Effects.task) ] )
        _ -> let (m, e) = PeoplePage.update peoplePageAction model.peoplePage
             in ({ model | peoplePage = m }, Effects.map DelegateToPeoplePage e)

    DelegateToHistoryPage historyPageAction ->
      let (m,e) = HistoryPage.update historyPageAction model.historyPage in
        ({ model | historyPage = m }, Effects.map DelegateToHistoryPage e)

    GotPeople maybePeople ->
      let (pm, pe) = PeoplePage.update (PeoplePage.GotPeople maybePeople) model.peoplePage
          (sm, se, sf) = SchedulePage.update (SchedulePage.GotPeople maybePeople) model.schedulePage
        --  (hm, he) = HistoryPage.update (HistoryPage.GotPeople maybePeople) model.historyPage
      in
        ({ model | peoplePage = pm, schedulePage = sm }, Effects.batch [ Effects.map DelegateToPeoplePage pe
                                                                        , Effects.map DelegateToSchedulePage se ] )

    TimeIsPassing t ->
      -- TODO: DRY (see DelegateToSchedulePage)
      let (m,e,f) = SchedulePage.update (SchedulePage.TimeIsPassing t) model.schedulePage in
        ({ model | schedulePage = m }, Effects.batch [ Effects.map DelegateToSchedulePage e
                                                        , case f of
                                                            Nothing -> Effects.none
                                                            Just s -> Effects.map NoOp1 (Signal.send model.focusAddress s |> Effects.task) ])
    KeysDown ks ->
      let -- TODO: Use set intersection. or even better keep model of deltas to keys down
        escPressed = Set.member 27 ks
        upPressed = Set.member 38 ks
        dnPressed = Set.member 40 ks
        ltPressed = Set.member 37 ks
        rtPressed = Set.member 39 ks
        entPressed = Set.member 13 ks
        (sm, se, sf) = if escPressed then SchedulePage.update (SchedulePage.KeyPressed 27) model.schedulePage
                       else if entPressed then SchedulePage.update (SchedulePage.KeyPressed 13) model.schedulePage
                       else if upPressed then SchedulePage.update (SchedulePage.KeyPressed 38) model.schedulePage
                       else if dnPressed then SchedulePage.update (SchedulePage.KeyPressed 40) model.schedulePage
                       else if ltPressed then SchedulePage.update (SchedulePage.KeyPressed 37) model.schedulePage
                       else if rtPressed then SchedulePage.update (SchedulePage.KeyPressed 39) model.schedulePage
                       else (model.schedulePage, Effects.none, Nothing)
      in
        ({model | schedulePage = sm}, Effects.map DelegateToSchedulePage se)



-- C-/ undo; C-e end of line; C-g escape; C-s RET search; C-d delete
    --37,38,39,40 = l,u,r,d
    -- 27=esc

-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div [] [
    PrimaryNav.view (Signal.forwardTo address DelegateToPrimaryNav) model.primaryNav,
    h3 [ ] [ text model.massage ],
    case model.activePage of
      "Schedule" ->
        SchedulePage.view (Signal.forwardTo address DelegateToSchedulePage) model.schedulePage
      "People" ->
        PeoplePage.view (Signal.forwardTo address DelegateToPeoplePage) model.peoplePage
      "History" ->
        HistoryPage.view (Signal.forwardTo address DelegateToHistoryPage) model.historyPage
      _ ->
        p [ ] [ text ("Page " ++ model.activePage ++ " is missing") ]
  ]

-- EFFECTS

getPeople =
  People.getPeople
  |> Task.map GotPeople
  |> Effects.task
