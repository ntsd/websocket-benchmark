package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{}

func binaryHandler(w http.ResponseWriter, r *http.Request) {
	conn, _ := upgrader.Upgrade(w, r, nil)
	for {
		_, p, _ := conn.ReadMessage()
		conn.WriteMessage(websocket.BinaryMessage, p)
	}
}

func jsonHandler(w http.ResponseWriter, r *http.Request) {
	conn, _ := upgrader.Upgrade(w, r, nil)
	for {
		_, p, _ := conn.ReadMessage()

		var f interface{}
		json.Unmarshal(p, &f)

		m, _ := json.Marshal(f)
		conn.WriteMessage(websocket.TextMessage, m)
	}
}

func plainHandler(w http.ResponseWriter, r *http.Request) {
	conn, _ := upgrader.Upgrade(w, r, nil)
	for {
		_, p, _ := conn.ReadMessage()
		conn.WriteMessage(websocket.TextMessage, p)
	}
}

func connectionHandler(w http.ResponseWriter, r *http.Request) {
	_, _ = upgrader.Upgrade(w, r, nil)
}

func main() {
	http.HandleFunc("/binary", binaryHandler)
	http.HandleFunc("/json", jsonHandler)
	http.HandleFunc("/plain", plainHandler)
	http.HandleFunc("/connection", connectionHandler)

	port := 9001
	log.Fatal(http.ListenAndServe(":"+strconv.Itoa(port), nil))
}
