module Repo where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, property)
import Http
import Json.Encode
import Task


-- Model.

type alias Model =
  { name: String -- Property.
  , description: String
  , readme: String
  }


init : String -> String -> (Model, Effects Action)
init name description =
  ( Model name description ""
  , fetchReadme name)


-- Update.

type Action
    = GetReadme (Maybe String)


update : Action -> Model -> (Model, Effects Action)
update action model =
  let
    getReadme = Maybe.withDefault ""
  in
    case action of
      GetReadme maybeReadme ->
        ( { model | readme = getReadme maybeReadme }
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
    , div
        [ readmeStyle
        , property "innerHTML" <| Json.Encode.string model.readme
        ] []
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
    [ "flex" => "1"
    , "max-height" => "200px"
    , "overflow" => "scroll"
    ]


-- Effects.

fetchReadme : String -> Effects Action
fetchReadme name =
  Http.send Http.defaultSettings
    { verb = "GET"
    , headers = [("Accept", "application/vnd.github.v3.html")]
    , url = readmeUrl name
    , body = Http.empty
    }
    |> Task.map handleReadmeResponse
    |> Task.toMaybe
    |> Task.map GetReadme
    |> Effects.task


handleReadmeResponse : Http.Response -> String
handleReadmeResponse response =
  if 200 <= response.status && response.status < 300 then
    case response.value of
      Http.Text readmeText -> readmeText
      _ -> "No README Found"
  else
    "No README Found"


readmeUrl : String -> String
readmeUrl name =
  "https://api.github.com/repos/edfward/" ++ name ++ "/readme"
