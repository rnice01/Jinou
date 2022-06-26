import {Elm, _} from './src/Main.elm'
import { invoke } from '@tauri-apps/api'

const app = Elm.Main.init({node: document.getElementById('main')})

app.ports.invokeLs.subscribe(function(dirPath) {
  invoke('listDirs', {rootPath: dirPath}).then(res => {
    app.ports.receiveResult.send(res)
  }).catch(err => {
    console.log(err)
    app.ports.receiveResult.send(err.msg)
  })
})
