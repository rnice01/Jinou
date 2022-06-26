port module Main exposing (..)

import Browser exposing (UrlRequest)
import Html exposing (Attribute, Html, a, br, button, div, li, node, text, ul)
import Html.Attributes exposing (attribute, href)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Url exposing (Url)

main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


init : () -> ( Model, Cmd Msg )
init _ = (initialModel, Cmd.none)


-- PORTS

type RustCmd = 
  LS

-- port invokeCommand : (RustCmd) -> Cmd msg
port invokeLs : String -> Cmd msg
port receiveResult : (Json.Decode.Value -> msg) -> Sub msg


-- Model
type alias Model =
    {
      files : List File
    }


type alias File =
  {
    name : String
    , isDir : Bool
    , path : String
  }


initialModel : Model
initialModel = { files = [] }


type Msg = 
    Init | InvokeLs String | OnUrlChange Url | OnUrlRequest UrlRequest | SetModel Model | NoOp | ChangeDirectory String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ChangeDirectory dirPath ->
      (model, invokeLs dirPath)
    Init ->
      (model, Cmd.none)

    InvokeLs path ->
      ( { model | files = [] }
      , invokeLs path
      )
    
    NoOp ->
      (model, Cmd.none)

    OnUrlChange _ ->
      (model, Cmd.none)
    
    OnUrlRequest _ ->
      (model, Cmd.none)

    SetModel updatedModel ->
      (updatedModel, Cmd.none)


view : Model -> Html Msg
view model =
  node "main"
  []
  [
    div []
      [ button [ onClick <| InvokeLs "." ] [ text "LS" ]
      , div []
          (List.map (\file -> fileDetails file) model.files)
      ]
  ]


fileDetails : File -> Html Msg
fileDetails file =
  let
    fileName = if file.isDir then
                li [] [a [href "#", onClick <| ChangeDirectory file.path] [text file.name]]
              else
                li [] [text file.name]
  in
  ul [] [
    fileName
    , li [] [text file.path]
  ]


--- Decoders
decodeResult : Json.Decode.Value -> Msg
decodeResult modelJson =
    case (Json.Decode.decodeValue decodeModel modelJson) of
        Ok model ->
            SetModel model

        Err errorMessage ->
            let
                _ =
                    Debug.log "Error in deocdeResult:" errorMessage
            in
                NoOp


decodeModel : Decoder Model
decodeModel =
    decodeFiles


decodeFiles : Json.Decode.Decoder Model
decodeFiles =
    Json.Decode.succeed Model
        |> required "files" (Json.Decode.list decodeFile)


decodeFile : Json.Decode.Decoder File
decodeFile =
    Json.Decode.map3 File
        (field "name" (Json.Decode.string))
        (field "isDir" (Json.Decode.bool))
        (field "path" (Json.Decode.string))


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
  [
    receiveResult decodeResult
  ]