#![cfg_attr(
  all(not(debug_assertions), target_os = "windows"),
  windows_subsystem = "windows"
)]
use std::process::Command;

#[tauri::command]
fn ls() -> Vec<String> {
  let output = Command::new("ls")
        .output()
        .expect("ls command failed to start");

        
  String::from_utf8(output.stdout).expect("").lines().map(|l| String::from(l)).collect()
}

fn main() {
  tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![ls])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
