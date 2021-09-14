package main

import (
	"archive/tar"
	"compress/gzip"
	"io"
	"net/http"
	"os"
	"syscall"
)

func main() {
	file_name := "st.tgz"

	println("Downlaoding...")
	download(file_name)

	println("\nUnzipping...")
	unzip(file_name)

	println("\nRunning...")
	println(syscall.Exec("/speedtest", append([]string{"/speedtest"}, os.Args[1:]...), os.Environ()))
}

func download(name string) {

	url := "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-" + os.Getenv("ARCH") + "-linux.tgz"

	print("\t", url+" ")
	resp, err := http.Get(url)

	if err == nil {
		println("✅")
	} else {
		println("❎")
	}

	defer resp.Body.Close()
	out, _ := os.Create(name)
	defer out.Close()
	io.Copy(out, resp.Body)
}

func unzip(file_name string) {

	gzipStream, _ := os.Open(file_name)
	uncompressedStream, _ := gzip.NewReader(gzipStream)
	tarReader := tar.NewReader(uncompressedStream)

	for {
		header, err := tarReader.Next()

		if err == io.EOF {
			break
		}

		print("\t" + header.Name + "\t")

		if header.Name == "speedtest" {
			outFile, _ := os.Create(header.Name)
			io.Copy(outFile, tarReader)
			outFile.Close()
			println("✅")
		} else {
			println("🗑️")
		}
	}
}
