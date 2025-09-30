#include <websocketpp/config/asio_no_tls.hpp>
#include <websocketpp/server.hpp>
#include <nlohmann/json.hpp>
#include <iostream>
#include <thread>
#include <functional>
#include <string>
#include <memory>
#include <cstring>
#include <map>

typedef websocketpp::server<websocketpp::config::asio> server;

using websocketpp::connection_hdl;
using websocketpp::lib::placeholders::_1;
using websocketpp::lib::placeholders::_2;
using websocketpp::lib::bind;

enum class endpoint_type {
    CONNECTION,
    PLAIN,
    JSON,
    BINARY
};

class websocket_server {
public:
    websocket_server() {
        // Disable all logging for benchmarking
        m_server.clear_error_channels(websocketpp::log::elevel::all);
        m_server.clear_access_channels(websocketpp::log::alevel::all);
        
        // Initialize Asio
        m_server.init_asio();
        
        // Set handlers
        m_server.set_validate_handler(bind(&websocket_server::validate_connection, this, _1));
        m_server.set_message_handler(bind(&websocket_server::on_message, this, _1, _2));
    }
    
    bool validate_connection(connection_hdl hdl) {
        server::connection_ptr con = m_server.get_con_from_hdl(hdl);
        
        std::string path = con->get_resource();
        endpoint_type type;
        
        if (path == "/connection") {
            type = endpoint_type::CONNECTION;
        } else if (path == "/plain") {
            type = endpoint_type::PLAIN;
        } else if (path == "/json") {
            type = endpoint_type::JSON;
        } else if (path == "/binary") {
            type = endpoint_type::BINARY;
        } else {
            return false; // Reject unknown paths
        }
        
        // Store the endpoint type for this connection
        m_connections[hdl] = type;
        return true;
    }
    
    void on_message(connection_hdl hdl, server::message_ptr msg) {
        try {
            auto it = m_connections.find(hdl);
            if (it == m_connections.end()) {
                return; // Connection not found
            }
            
            endpoint_type type = it->second;
            
            switch (type) {
                case endpoint_type::CONNECTION:
                    // Connection endpoint doesn't handle messages
                    break;
                    
                case endpoint_type::PLAIN:
                    // Echo back the message as-is
                    m_server.send(hdl, msg->get_payload(), websocketpp::frame::opcode::text);
                    break;
                    
                case endpoint_type::JSON:
                    handle_json_message(hdl, msg);
                    break;
                    
                case endpoint_type::BINARY:
                    handle_binary_message(hdl, msg);
                    break;
            }
        } catch (websocketpp::exception const& e) {
            std::cout << "Message handler exception: " << e.what() << std::endl;
        }
    }
    
    void handle_json_message(connection_hdl hdl, server::message_ptr msg) {
        try {
            const std::string& payload = msg->get_payload();
            nlohmann::json json_msg = nlohmann::json::parse(payload);
            
            if (json_msg.contains("number") && json_msg["number"].is_number()) {
                int32_t num = json_msg["number"].get<int32_t>();
                
                // Apply transformation logic
                if (num % 2 == 0) {
                    num += 2;
                } else {
                    num += 1;
                }
                
                json_msg["number"] = num;
                std::string response = json_msg.dump();
                m_server.send(hdl, response, websocketpp::frame::opcode::text);
            }
        } catch (const nlohmann::json::exception& e) {
            // Invalid JSON, ignore
        }
    }
    
    void handle_binary_message(connection_hdl hdl, server::message_ptr msg) {
        const std::string& payload = msg->get_payload();
        if (payload.size() == 4) {
            // Convert 4 bytes to int32_t (little endian)
            int32_t num;
            std::memcpy(&num, payload.data(), 4);
            
            // Apply transformation logic
            if (num % 2 == 0) {
                num += 2;
            } else {
                num += 1;
            }
            
            // Send back as binary (little endian)
            std::string response(4, '\0');
            std::memcpy(&response[0], &num, 4);
            m_server.send(hdl, response, websocketpp::frame::opcode::binary);
        }
    }
    
    void run(uint16_t port) {
        // Set up connection cleanup
        m_server.set_close_handler([this](connection_hdl hdl) {
            m_connections.erase(hdl);
        });
        
        // Listen on specified port
        m_server.listen(port);
        
        // Start the server accept loop
        m_server.start_accept();
        
        std::cout << "WebSocket++ server listening on port " << port << std::endl;
        
        // Start the ASIO io_service run loop
        m_server.run();
    }

private:
    server m_server;
    std::map<connection_hdl, endpoint_type, std::owner_less<connection_hdl>> m_connections;
};

int main() {
    websocket_server server;
    
    try {
        server.run(9001);
    } catch (websocketpp::exception const& e) {
        std::cout << "Exception: " << e.what() << std::endl;
    } catch (...) {
        std::cout << "Unknown exception" << std::endl;
    }
    
    return 0;
}