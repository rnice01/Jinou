#![cfg_attr(
  all(not(debug_assertions), target_os = "windows"),
  windows_subsystem = "windows"
)]
use std::fs;
use std::path::PathBuf;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct File {
  name: String,
  path: String,
  isDir: bool
}

#[derive(Serialize, Deserialize)]
struct Model {
  files: Vec<File>,
}

#[tauri::command]
fn listDirs(root_path: String) -> Model {
  let files = fs::read_dir(&root_path).expect("").map(|e| { 
    let entry = e.unwrap();

    let is_dir = match entry.file_type() {
      Ok(ft) => ft.is_dir(),
      Err(_) =>false
    };

    let mut full_path : PathBuf = PathBuf::from(&root_path);
    full_path.push(entry.path());

    let string_path = full_path.into_os_string().into_string().unwrap_or_default();

    File {
      name: entry.file_name().into_string().unwrap(),
      isDir: is_dir,
      path: string_path
    }
  }).collect();

  Model {
    files: files
  }
}

fn main() {
  tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![listDirs])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
