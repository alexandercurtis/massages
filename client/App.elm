module App where

import Container exposing (init, update, view, timeSignal, keyboardSignal, Model)
import Effects exposing (Never)
import StartApp
import Task



app =
  StartApp.start
    { init = init focusMailbox.address
    , update = update
    , view = view
    , inputs = [timeSignal,keyboardSignal]
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

focusMailbox : Signal.Mailbox String
focusMailbox =
  Signal.mailbox ""


port focus : Signal String
port focus =
  focusMailbox.signal
