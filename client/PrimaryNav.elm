module PrimaryNav where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)

-- MODEL

type alias Model =
    { options : List String,
      selected : String
    }

init : List String -> String -> Model
init options selected =
    { options = options
    , selected = selected
    }

-- UPDATE

type Action
    = NoOp
    | OptionSelected String

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)
    OptionSelected option ->
      ({ model | selected = option }, Effects.none)

-- VIEW

renderOption : Signal.Address Action -> String -> String -> Html
renderOption address selectedOption option =
  li
    [ classList [ ("highlight", option == selectedOption) ],
      onClick address (OptionSelected option) ]
    [ text option ]


view : Signal.Address Action -> Model -> Html
view address model =
  let
    items = List.map (renderOption address model.selected) model.options
  in
    ul [ class "primary-nav" ] items
