port module Main exposing (..)

import Browser exposing (UrlRequest)
import Html exposing (Html, button, div, li, node, text, ul)
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
port invokeLs : () -> Cmd msg
port receiveResult : (Json.Decode.Value -> msg) -> Sub msg


-- Model
type alias Model =
    {
      files : List File
    }


type alias File =
  {
    name : String
  }


initialModel : Model
initialModel = { files = [] }


type Msg = 
    Init | InvokeLs | OnUrlChange Url | OnUrlRequest UrlRequest | SetModel Model | NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Init ->
      (model, Cmd.none)

    InvokeLs ->
      ( { model | files = [] }
      , invokeLs()
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
      [ button [ onClick InvokeLs ] [ text "LS" ]
      , ul []
          (List.map (\file -> li [] [ text file.name ]) model.files)
      ]
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
    Json.Decode.succeed File
        |> required "name" (Json.Decode.string)


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
  [
    receiveResult decodeResult
  ]