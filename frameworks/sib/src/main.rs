#[global_allocator]
static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;

use sib::network::http::server::{H1Config, HFactory};
use sib::network::http::session::{HService, Session};
use sib::network::http::ws::OpCode;

struct WsBench;

impl HService for WsBench {
    fn call<SE: Session>(&mut self, session: &mut SE) -> std::io::Result<()> {
        use bytes::{Bytes, BytesMut};

        let path = session.req_path();

        // Only serve WebSocket on this port.
        if !session.is_ws() {
            let body = Bytes::from_static(b"upgrade to websocket");
            let len = body.len().to_string();
            return session
                .status_code(http::StatusCode::NOT_FOUND)
                .header(
                    http::header::CONTENT_TYPE,
                    http::HeaderValue::from_static("text/plain"),
                )?
                .header(
                    http::header::CONTENT_LENGTH,
                    http::HeaderValue::from_str(&len).unwrap(),
                )?
                .body(body)
                .eom();
        }

        // 101 upgrade for H1
        session.ws_accept()?;

        // Connection-speed test: 101 then close immediately at "/"
        if path == "/" {
            let _ = session.ws_close(None);
            return Err(std::io::Error::new(
                std::io::ErrorKind::ConnectionAborted,
                "ws handshake-only done",
            ));
        }

        // Fragmentation state
        let mut frag_buf = BytesMut::new();
        let mut expecting_continuation = false;
        let mut initial_opcode = OpCode::Text;

        // Text handler: zero-copy when we can
        let handle_text = |route: &str, s_bytes: &Bytes| -> (OpCode, Bytes) {
            match route {
                "/plain" => (OpCode::Text, s_bytes.clone()), // zero-copy
                "/json" => {
                    if let Ok(mut v) = serde_json::from_slice::<serde_json::Value>(s_bytes.as_ref())
                    {
                        if let Some(num) = v.get_mut("number") {
                            if let Some(i) = num.as_i64() {
                                *num = (i + if i % 2 == 0 { 2 } else { 1 }).into();
                            }
                        }
                        let out = v.to_string();
                        (OpCode::Text, Bytes::from(out)) // alloc only when transforming
                    } else {
                        (OpCode::Text, s_bytes.clone())
                    }
                }
                _ => (OpCode::Text, s_bytes.clone()),
            }
        };

        // Binary handler: zero-copy unless we transform first 4 bytes
        let handle_binary = |route: &str, buf: &Bytes| -> (OpCode, Bytes) {
            match route {
                "/binary" => {
                    if buf.len() >= 4 {
                        let mut arr = [0u8; 4];
                        arr.copy_from_slice(&buf[..4]);
                        let mut n = u32::from_le_bytes(arr);
                        n += if n % 2 == 0 { 2 } else { 1 };
                        (OpCode::Binary, Bytes::copy_from_slice(&n.to_le_bytes()))
                    } else {
                        (OpCode::Binary, buf.clone())
                    }
                }
                _ => (OpCode::Binary, buf.clone()),
            }
        };

        loop {
            let (op, payload, fin) = session.ws_read()?; // payload: Bytes

            match op {
                OpCode::Ping => {
                    // zero-copy echo
                    session.ws_write(OpCode::Pong, &payload, true)?;
                }
                OpCode::Pong => { /* ignore */ }
                OpCode::Close => {
                    session.ws_close(None)?;
                    break;
                }
                OpCode::Text | OpCode::Binary => {
                    if !fin {
                        // start a fragmented message
                        frag_buf.clear();
                        frag_buf.extend_from_slice(payload.as_ref());
                        expecting_continuation = true;
                        initial_opcode = op;
                        continue;
                    }

                    // single-frame message
                    match op {
                        OpCode::Text => {
                            if std::str::from_utf8(payload.as_ref()).is_ok() {
                                let (reply_op, out) = handle_text(&path, &payload);
                                session.ws_write(reply_op, &out, true)?;
                            } else {
                                // invalid UTF-8 → echo as binary (zero-copy)
                                session.ws_write(OpCode::Binary, &payload, true)?;
                            }
                        }
                        OpCode::Binary => {
                            let (reply_op, out) = handle_binary(&path, &payload);
                            session.ws_write(reply_op, &out, true)?;
                        }
                        _ => {}
                    }
                }
                OpCode::Continue => {
                    if !expecting_continuation {
                        // protocol error
                        session.ws_close(None)?;
                        break;
                    }
                    frag_buf.extend_from_slice(payload.as_ref());
                    if fin {
                        expecting_continuation = false;

                        // freeze once -> Bytes (no extra copy)
                        let whole = frag_buf.split().freeze();

                        match initial_opcode {
                            OpCode::Text => {
                                if std::str::from_utf8(whole.as_ref()).is_ok() {
                                    let (reply_op, out) = handle_text(&path, &whole);
                                    session.ws_write(reply_op, &out, true)?;
                                } else {
                                    session.ws_write(OpCode::Binary, &whole, true)?;
                                }
                            }
                            OpCode::Binary => {
                                let (reply_op, out) = handle_binary(&path, &whole);
                                session.ws_write(reply_op, &out, true)?;
                            }
                            _ => {}
                        }
                        // frag_buf already drained by split()
                    }
                }
            }
        }

        // Close connection after WS session
        Err(std::io::Error::new(
            std::io::ErrorKind::ConnectionAborted,
            "ws done",
        ))
    }
}

// Wire it to the factory so we can start the H1 server.
impl HFactory for WsBench {
    type Service = Self;

    fn service(&self, _id: usize) -> Self::Service {
        WsBench
    }
}

fn main() {
    let stack_size = 4 * 1024; // 4 KB stack
    let cpus = num_cpus::get();

    sib::init_global_poller(cpus, stack_size);

    // Pick a port and start the server
    let addr = "0.0.0.0:9001";
    let mut threads = Vec::with_capacity(cpus);

    for _ in 0..cpus {
        let handle = std::thread::spawn(move || {
            let id = std::thread::current().id();
            println!("Listening {addr} on thread: {id:?}");
            WsBench
                .start_h1(
                    addr,
                    H1Config {
                        io_timeout: std::time::Duration::from_secs(15),
                        stack_size,
                    },
                )
                .unwrap_or_else(|_| panic!("H1 WS server failed to start for thread {id:?}"))
                .join()
                .unwrap_or_else(|_| panic!("H1 WS server failed to join thread {id:?}"));
        });
        threads.push(handle);
    }

    for handle in threads {
        handle.join().expect("Thread panicked");
    }
}
