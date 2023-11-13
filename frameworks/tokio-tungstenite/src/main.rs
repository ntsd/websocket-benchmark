use futures_util::{SinkExt, StreamExt};
use tokio::net::{TcpListener, TcpStream};
use tokio_tungstenite::{
    accept_async,
    tungstenite::{Error, Message, Result},
};

async fn accept_connection(stream: TcpStream) {
    if let Err(e) = handle_connection(stream).await {
        match e {
            Error::ConnectionClosed | Error::Protocol(_) | Error::Utf8 => (),
            err => println!("Error processing connection: {}", err),
        }
    }
}

async fn handle_connection(stream: TcpStream) -> Result<()> {
    let mut ws_stream = accept_async(stream).await.expect("Failed to accept");

    while let Some(msg) = ws_stream.next().await {
        let msg = msg?;
        if msg.is_binary() {
            let bytes: Vec<u8> = msg.into_data();
            let array: [u8; 4] = bytes.try_into().unwrap();
            let mut num: u32 = u32::from_le_bytes(array);

            if num % 2 == 0 {
                num += 2;
            } else {
                num += 1;
            }

            ws_stream.send(Message::binary(num.to_le_bytes())).await?;
        } else if msg.is_text() {
            let json: Result<serde_json::Value, serde_json::error::Error> =
                serde_json::from_str(&msg.to_string());
            if let Ok(mut json) = json {
                let mut num = json["number"].as_i64().expect("number is not a number");
                if num % 2 == 0 {
                    num += 2;
                } else {
                    num += 1;
                }
                json["number"] = num.into();

                ws_stream.send(Message::Text(json.to_string())).await?;
            } else {
                ws_stream.send(msg).await?;
            }
        }
    }

    Ok(())
}

#[tokio::main]
async fn main() {
    let addr = "0.0.0.0:9001";
    let listener = TcpListener::bind(&addr).await.expect("Failed to bind");
    println!("Listening on: {}", addr);

    while let Ok((stream, _)) = listener.accept().await {
        tokio::spawn(accept_connection(stream));
    }
}
