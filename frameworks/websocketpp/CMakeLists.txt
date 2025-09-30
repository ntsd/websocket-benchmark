cmake_minimum_required(VERSION 3.10)
project(websocketpp_server)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(Threads REQUIRED)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(/opt/websocketpp)

# Add executable
add_executable(websocketpp_server server.cpp)

# Link libraries
target_link_libraries(websocketpp_server Threads::Threads)

# Compiler-specific options
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    target_compile_options(websocketpp_server PRIVATE -Wall -Wextra -O2)
endif()

# System-specific linking
if(WIN32)
    target_link_libraries(websocketpp_server ws2_32 wsock32)
elseif(UNIX AND NOT APPLE)
    target_link_libraries(websocketpp_server pthread)
endif()