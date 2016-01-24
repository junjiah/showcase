import Effects exposing (Never)
import RepoList exposing (init, update, view)
import StartApp
import Task

import Config exposing (username)


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main = app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


port title : String
port title = username ++ "'s showcase"
