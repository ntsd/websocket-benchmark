package main

import (
	"bytes"
	"encoding/binary"
	"log"
	"net/http"
	"strconv"

	"github.com/bytedance/sonic"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{}

func binaryHandler(w http.ResponseWriter, r *http.Request) {
	conn, _ := upgrader.Upgrade(w, r, nil)
	defer conn.Close()

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			return
		}

		var intMessage int32
		buf := bytes.NewReader(p)
		binary.Read(buf, binary.LittleEndian, &intMessage)

		if intMessage%2 == 0 {
			intMessage += 2
		} else {
			intMessage += 1
		}

		resBuf := new(bytes.Buffer)
		_ = binary.Write(resBuf, binary.LittleEndian, intMessage)

		conn.WriteMessage(websocket.BinaryMessage, resBuf.Bytes())
	}
}

func jsonHandler(w http.ResponseWriter, r *http.Request) {
	conn, _ := upgrader.Upgrade(w, r, nil)
	defer conn.Close()

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			// websocket closed
			return
		}

		var f map[string]int
		sonic.Unmarshal(p, &f)

		if f["number"]%2 == 0 {
			f["number"] += 2
		} else {
			f["number"] += 1
		}

		m, _ := sonic.Marshal(f)
		conn.WriteMessage(websocket.TextMessage, m)
	}
}

func plainHandler(w http.ResponseWriter, r *http.Request) {
	conn, _ := upgrader.Upgrade(w, r, nil)
	defer conn.Close()

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			// websocket closed
			return
		}

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
