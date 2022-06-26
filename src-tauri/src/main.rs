#![cfg_attr(
  all(not(debug_assertions), target_os = "windows"),
  windows_subsystem = "windows"
)]
use std::process::Command;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct File {
  name: String
}

#[derive(Serialize, Deserialize)]
struct Model {
  files: Vec<File>,
}

#[tauri::command]
fn ls() -> Model {
  let output = Command::new("ls")
        .output()
        .expect("ls command failed to start");

        
  let files = String::from_utf8(output.stdout).expect("Failed to convert command bytes to String").lines().map(|l| File { name: String::from(l) }).collect();

  Model {
    files: files
  }
}

fn main() {
  tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![ls])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
