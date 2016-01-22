module RepoList where

import Effects exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json

import Repo


-- Model.

type alias Model =
  { repoList : List (Int, Repo.Model)
  , user : String
  , uid : Int
  }


username : String
username = "edfward"


init : (Model, Effects Action)
init =
  ( Model [] username 0
  , Effects.none
  )


-- Update.

type Action
  = Create
  | ShowSub Int Repo.Action

update : Action -> Model -> (Model, Effects Action)
update message model =
  case message of
    Create ->
      let
        (newRepo, fx) = Repo.init
        newModel = Model (model.repoList ++ [(model.uid, newRepo)]) username (model.uid + 1)
      in
        ( newModel
        , map (ShowSub model.uid) fx
        )
    ShowSub id repoAction ->
      let
        subUpdate ((repoId, repoModel) as entry) =
          if repoId == id then
            let
              (newRepo, fx) = Repo.update repoAction repoModel
            in
              ( (repoId, newRepo)
              , map (ShowSub repoId) fx
              )
          else
            (entry, Effects.none)

        (newRepoList, fxList) =
          model.repoList
            |> List.map subUpdate
            |> List.unzip
      in
        ( { model | repoList = newRepoList }
        , batch fxList
        )


-- View.

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ button [onClick address Create, style [ "position" => "fixed" ]] [ text "Load repo!" ],

  div [ style [ "min-height" => "100vh", "display" => "flex" ] ]
    [ nav [ style [ "flex" => "0 0 12em" ] ] []
    , main' [ style [ "flex" => "1" ] ]
        (List.map (elementView address) model.repoList)
    , aside [ style [ "flex" => "0 0 12em" ] ] []
    ]

    ]

elementView : Signal.Address Action -> (Int, Repo.Model) -> Html
elementView address (id, model) =
  Repo.view (Signal.forwardTo address (ShowSub id)) model
