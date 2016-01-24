module RepoList where

import Effects exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing ((:=))
import Task

import GithubKey exposing (githubKey)
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
            (repo, fx) = Repo.init info.name username info.url info.description
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

-- Also as an entry point to the HTML.
view : Signal.Address Action -> Model -> Html
view address model =
  div [ backgroundStyle ]
    [ css "style.css"
    , css "https://fonts.googleapis.com/css?family=Roboto:100,300,300italic,700,700italic"
    , css "https://fonts.googleapis.com/css?family=Raleway:100"
    , css "https://fonts.googleapis.com/css?family=Source+Sans+Pro:300"
    , nav [ style [ "flex" => "0 0 12em" ] ] []
    , main' [ style [ "flex" => "1" ] ]
        ( siteTitle :: (List.intersperse separater
                        <| List.map (elementView address) model.repoList)
        )
    , aside [ style [ "flex" => "0 0 12em" ] ] []
    ]


elementView : Signal.Address Action -> (Int, Repo.Model) -> Html
elementView address (id, model) =
  Repo.view (Signal.forwardTo address (ShowSub id)) model


css : String -> Html
css path =
  node "link" [ rel "stylesheet", href path ] []


siteTitle : Html
siteTitle =
  h1 [ style [ "margin-top" => "100px"
             , "font-family" => "\"Source Sans Pro\", \"Helvetica Neue\", Helvetica, Arial, sans-serif"
             , "font-weight" => "300"
             ] ]
    -- Hardcoded URL.
    [ a [ href "http://showcase.edfward.com"
        , style [ "color" => "grey", "text-decoration" => "none" ]
        ]
      [ text "edfward"
      , span [ style [ "color" => "#DDD" ] ] [ text "'s showcase" ]
      ]
    ]

separater : Html
separater =
  div [ style [ "margin" => "0 auto"
              , "height" => "9px"
              , "width" => "576px"
              , "background" => "url(\"separator.png\")"
              , "-webkit-filter" => "invert(100%)"
              , "filter" => "invert(100%)"
              ]
  ] []


backgroundStyle : Attribute
backgroundStyle =
  style
    [ "min-height" => "100vh"
    , "display" => "flex"
    , "background" => "#252525"
    ]


-- Effects.

fetchRepoList : Effects Action
fetchRepoList =
  Http.get decodeUrl repoListUrl
    |> Task.map (List.take 10)
    |> Task.toMaybe
    |> Task.map InitRepoList
    |> Effects.task


repoListUrl : String
repoListUrl =
  Http.url "https://api.github.com/users/edfward/repos"
    [ ("sort", "pushed")
    , ("access_token", githubKey)
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
