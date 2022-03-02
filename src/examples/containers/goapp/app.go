package main

import (
	"fmt"
	"net/http"
	"os"
)

const (
	VERSION = 1
)

func hostnameHandler(w http.ResponseWriter, r *http.Request) {
	myhostname, _ := os.Hostname()
	fmt.Fprintln(w, "Hostname:", myhostname, " Version:", VERSION)
}

func main() {
	const port string = "8000"
	fmt.Println("Server listening on port", port)
	http.HandleFunc("/", hostnameHandler)
	http.ListenAndServe(":"+port, nil)
}
