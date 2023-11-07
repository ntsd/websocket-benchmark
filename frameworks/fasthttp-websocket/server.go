package main

import (
	"bytes"
	"encoding/binary"
	"log"

	"github.com/bytedance/sonic"
	"github.com/fasthttp/websocket"
	"github.com/valyala/fasthttp"
)

var upgrader = websocket.FastHTTPUpgrader{
	CheckOrigin: func(ctx *fasthttp.RequestCtx) bool { return true },
}

func binaryHandler(ctx *fasthttp.RequestCtx) {
	upgrader.Upgrade(ctx, func(conn *websocket.Conn) {
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
	})
}

func jsonHandler(ctx *fasthttp.RequestCtx) {
	upgrader.Upgrade(ctx, func(conn *websocket.Conn) {
		defer conn.Close()

		for {
			_, p, err := conn.ReadMessage()
			if err != nil {
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
	})
}

func plainHandler(ctx *fasthttp.RequestCtx) {
	upgrader.Upgrade(ctx, func(conn *websocket.Conn) {
		defer conn.Close()

		for {
			messageType, p, err := conn.ReadMessage()
			if err != nil {
				return
			}

			conn.WriteMessage(messageType, p)
		}
	})
}

func connectionHandler(ctx *fasthttp.RequestCtx) {
	upgrader.Upgrade(ctx, func(conn *websocket.Conn) {
	})
}

func main() {
	router := func(ctx *fasthttp.RequestCtx) {
		switch string(ctx.Path()) {
		case "/binary":
			binaryHandler(ctx)
		case "/json":
			jsonHandler(ctx)
		case "/plain":
			plainHandler(ctx)
		case "/connection":
			connectionHandler(ctx)
			return
		}
	}

	log.Fatal(fasthttp.ListenAndServe(":9001", router))
}
