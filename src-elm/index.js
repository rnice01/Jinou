import {Elm, _} from './src/Main.elm'
import { invoke } from '@tauri-apps/api'

const app = Elm.Main.init({node: document.getElementById('main')})

app.ports.invokeLs.subscribe(function() {
  invoke('ls').then(res => {
    app.ports.receiveResult.send(res)
  }).catch(err => {
    app.ports.lsError.send(err.msg)
  })
})
