package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func HelloServer(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		fmt.Fprintf(w, "Hello World")
	} else if r.Method == "POST" {
		decoder := json.NewDecoder(r.Body)
		var obj interface{}
		err := decoder.Decode(&obj)
		if err != nil {
			fmt.Fprintf(w, "Error %v", err)
			return
		}
		data, err := json.Marshal(obj)
		if err != nil {
			fmt.Fprintf(w, "Error %v", err)
			return
		}
		w.Write(data)
	}
}

func main() {
	fmt.Println("Listening on :3000")
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":3000", nil)
}
