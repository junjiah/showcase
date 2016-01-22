module Repo where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style)
import Http
import Json.Decode as Json
import Task


-- Model.

type alias Model =
  { name: String -- Property.
  , description: String
  , readme: String
  }

name = "ReadKeyServer"

init : (Model ,Effects Action)
init =
  ( Model name "" ""
  , fetchRepo name)


-- Update.

type Action
    = RepoInfo (Maybe String)


update : Action -> Model -> (Model, Effects Action)
update action model =
  let
    getDescription = Maybe.withDefault "DESC"
  in
    case action of
      RepoInfo maybeDescription ->
        ( Model model.name (getDescription maybeDescription) (getDescription maybeDescription)
        , Effects.none
        )


-- View.

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div [ projectStyle ]
    [ div [ descriptionStyle ]
      [ h3 [] [ text model.name ]
      , p [] [text model.description ]
      ]
    , div [ readmeStyle ]
      [ p [] [ text model.readme ] ]
    ]


projectStyle: Attribute
projectStyle =
  style
    [ "display" => "flex"
    , "padding-top" => "125px"
    , "padding-bottom" => "130px"
    ]


descriptionStyle : Attribute
descriptionStyle =
  style
    [ "flex" => "1" ]


readmeStyle : Attribute
readmeStyle =
  style
    [ "flex" => "1" ]


-- Effects.

fetchRepo : String -> Effects Action
fetchRepo name =
  Http.get decodeUrl (repoUrl name)
    |> Task.toMaybe
    |> Task.map RepoInfo
    |> Effects.task


repoUrl : String -> String
repoUrl name =
  Http.url ("https://api.github.com/repos/edfward/" ++ name) []


decodeUrl : Json.Decoder String
decodeUrl =
  Json.at [ "description" ] Json.string
