use flate2::read::GzDecoder;
use std::{env::args, io::Cursor, process::Command};
use tar::Archive;

fn main() {
    let url = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-x86_64-linux.tgz";

    // print!("Downloading...\n\t{}", url);
    let downloaded = Cursor::new(
        reqwest::blocking::get(url)
            .expect(" ❌ Couldn't reach url")
            .bytes()
            .expect(" ❌ Couldn't download file"),
    );
    // println!(" ✅");

    // println!("\nExtracting...");
    let mut archive = Archive::new(GzDecoder::new(downloaded));
    archive.unpack(".").expect(" ❌ Couldn't extract file");
    // println!("\t{} ✅", name);

    // println!("\nRunning...");
    Command::new("./speedtest")
        .args(&args().collect::<Vec<String>>()[1..])
        .status()
        .expect(" ❌ Failed to call process");
}
