module Repo (..) where

import Effects exposing (Effects, Never, batch)
import Html exposing (..)
import Html.Attributes exposing (class, href, property, style)
import Http
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))
import String
import Task
import Config exposing (githubKey)


-- Model.


type alias RepoLang =
    { lang : String
    , byteNum : Float
    }


type alias Model =
    { username :
        String
        -- Property.
    , repoName :
        String
        -- Property.
    , url :
        String
        -- Property.
    , description :
        String
        -- Property.
    , readme :
        String
        -- Fetched raw HTML.
    , langs :
        List ( String, Float )
        -- Fetched language / percentage list.
    }


init : String -> String -> String -> String -> ( Model, Effects Action )
init username repoName url description =
    ( Model username repoName url description "" []
    , batch [ fetchReadme username repoName, fetchLang username repoName ]
    )



-- Update.


type Action
    = ShowReadme (Maybe String)
    | ShowLang (Maybe (List RepoLang))


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        ShowReadme maybeReadme ->
            let
                readme =
                    Maybe.withDefault "" maybeReadme
            in
                ( { model | readme = readme }
                , Effects.none
                )

        ShowLang maybeLangList ->
            let
                langList =
                    Maybe.withDefault [] maybeLangList

                byteSum =
                    List.sum <| List.map .byteNum langList

                getFraction : Float -> Float
                getFraction i =
                    (i / byteSum * 1000) |> round |> toFloat |> \x -> x / 10

                langs =
                    List.map (\rl -> ( rl.lang, getFraction rl.byteNum )) langList
                        |> List.sortBy snd
                        |> List.reverse
            in
                ( { model | langs = langs }
                , Effects.none
                )



-- View.


(=>) =
    (,)


view : Signal.Address Action -> Model -> Html
view address model =
    div [ projectStyle ]
        [ div [ descriptionStyle ]
            [ div []
                [ h1 [ titleStyle ]
                    [ a
                        [ href model.url
                        , titleLinkStyle
                          -- A hack to inject styles of pseudo class ':hover'.
                        , class "repo-title"
                        ]
                        [ text model.repoName ]
                    ]
                , p [ style [ "color" => "#EDECEC" ] ] [ text model.description ]
                ]
            , div []
                [ ul [ langListStyle ] (List.map langView model.langs) ]
            ]
        , div
            [ readmeStyle
            , property "innerHTML" <| JE.string model.readme
            ]
            []
        ]


projectStyle : Attribute
projectStyle =
    style
        [ "display" => "flex"
        , "padding-top" => "125px"
        , "padding-bottom" => "130px"
        , "font-family" => "\"Roboto\",\"Helvetica Neue\",Helvetica,Arial,sans-serif"
        ]


descriptionStyle : Attribute
descriptionStyle =
    style
        [ "flex" => "1"
        , "display" => "flex"
        , "flex-direction" => "column"
        , "justify-content" => "space-between"
        , "color" => "whitesmoke"
        ]


titleStyle : Attribute
titleStyle =
    style
        [ "white-space" => "nowrap"
        , "text-overflow" => "ellipsis"
        , "overflow" => "hidden"
        , "font-family" => "Raleway,\"Roboto\",\"Helvetica Neue\",Helvetica,Arial,sans-serif"
        , "font-weight" => "100"
        ]


titleLinkStyle : Attribute
titleLinkStyle =
    style
        [ "color" => "whitesmoke"
        , "transition" => "color 200ms ease-in-out"
        , "text-decoration" => "none"
        ]


langListStyle : Attribute
langListStyle =
    style
        [ "list-style" => "none"
        , "padding" => "0"
        , "font-size" => "12px"
        , "font-weight" => "bold"
        ]


langView : ( String, Float ) -> Html
langView ( lang, fraction ) =
    li
        [ style
            [ "display" => "inline-block"
            , "line-height" => "20px"
            , "padding" => "4px 18px"
            , "padding-left" => "0"
            ]
        ]
        [ text lang
        , span
            [ style
                [ "color" => "grey"
                , "padding-left" => "9px"
                ]
            ]
            [ text <| (toString fraction ++ "%") ]
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


fetchReadme : String -> String -> Effects Action
fetchReadme username repoName =
    Http.send Http.defaultSettings
        { verb = "GET"
        , headers =
            [ ( "Accept", "application/vnd.github.v3.html" )
            , ( "Authorization", "token " ++ githubKey )
            ]
        , url = resourceUrl "readme" username repoName
        , body = Http.empty
        }
        |> Task.map handleReadmeResponse
        |> Task.toMaybe
        |> Task.map ShowReadme
        |> Effects.task


handleReadmeResponse : Http.Response -> String
handleReadmeResponse response =
    if 200 <= response.status && response.status < 300 then
        case response.value of
            Http.Text readmeText ->
                readmeText

            _ ->
                "<p>Failed to fetch README</p>"
    else
        "<p>Failed to fetch README</p>"


fetchLang : String -> String -> Effects Action
fetchLang username repoName =
    let
        url =
            Http.url (resourceUrl "languages" username repoName)
                [ ( "access_token", githubKey ) ]
    in
        Http.get decodeLang url
            |> Task.toMaybe
            |> Task.map ShowLang
            |> Effects.task


resourceUrl : String -> String -> String -> String
resourceUrl resource username repoName =
    String.join "/"
        [ "https://api.github.com/repos", username, repoName, resource ]


decodeLang : JD.Decoder (List RepoLang)
decodeLang =
    JD.keyValuePairs JD.float
        |> JD.map (List.map <| uncurry RepoLang)
