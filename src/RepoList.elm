module RepoList where

import Effects exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing ((:=))
import Task

import Repo


-- Model.

type alias RepoInfo =
  { name: String, url: String, description: String, stars: Int }


type alias Model =
  { repoList : List (Int, Repo.Model)
  , user : String
  }


username : String
username = "edfward"


init : (Model, Effects Action)
init =
  ( Model [] username
  , fetchRepoList
  )


-- Update.

type Action
  = InitRepoList (Maybe (List RepoInfo))
  | ShowSub Int Repo.Action

update : Action -> Model -> (Model, Effects Action)
update message model =
  case message of
    InitRepoList maybeRepoInfoList ->
      let
        repoInfoList = Maybe.withDefault [] maybeRepoInfoList
        makeEntry index info =
          let
            (repo, fx) = Repo.init info.name info.description
          in
            ((index, repo), map (ShowSub index) fx)
        (repos, fxList) = List.indexedMap makeEntry repoInfoList |> List.unzip
      in
        ( Model repos username
        , batch fxList
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
  div [ style [ "min-height" => "100vh", "display" => "flex" ] ]
    [ nav [ style [ "flex" => "0 0 12em" ] ] []
    , main' [ style [ "flex" => "1" ] ]
        (List.map (elementView address) model.repoList)
    , aside [ style [ "flex" => "0 0 12em" ] ] []
    ]


elementView : Signal.Address Action -> (Int, Repo.Model) -> Html
elementView address (id, model) =
  Repo.view (Signal.forwardTo address (ShowSub id)) model


-- Effects.


fetchRepoList : Effects Action
fetchRepoList =
  Http.get decodeUrl repoListUrl
    |> Task.map (List.take 3)
    |> Task.toMaybe
    |> Task.map InitRepoList
    |> Effects.task


repoListUrl : String
repoListUrl =
  Http.url "https://api.github.com/users/edfward/repos"
    [ ("sort", "pushed")
    , ("access_token", "###ACCESS_TOKEN###")
    ]


decodeUrl : Json.Decoder (List RepoInfo)
decodeUrl =
  let
    repo =
      Json.object4 RepoInfo
        ("name" := Json.string)
        ("html_url" := Json.string)
        ("description" := Json.string)
        ("stargazers_count" := Json.int)
  in
    Json.list repo
