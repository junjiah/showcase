module Repo where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (class, href, property, style)
import Http
import Json.Encode
import Task


-- Model.

type alias Model =
  { name: String  -- Property.
  , username : String  -- Property.
  , url : String  -- Property.
  , description: String  -- Property.
  , readme: String  -- Fetched raw HTML.
  }


init : String -> String -> String -> String -> (Model, Effects Action)
init name username url description =
  ( Model name username url description ""
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
        [ h1 []
            [ a [ href model.url
                , titleStyle
                , class "repotitle" ]
                [ text model.name ] ]
        , p [ style [ "color" => "#EDECEC" ] ] [text model.description ]
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


titleStyle : Attribute
titleStyle =
  style
    [ "color" => "#F19A2C"
    , "transition" => "color 200ms ease-in-out"
    ]


readmeStyle : Attribute
readmeStyle =
  style
    [ "flex" => "1"
    , "max-height" => "320px"
    , "overflow" => "scroll"
    , "color" => "#EDECEC"
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
      _ -> "<p>No README Found</p>"
  else
    "<p>No README Found</p>"


readmeUrl : String -> String
readmeUrl name =
  "https://api.github.com/repos/edfward/" ++ name ++ "/readme"
