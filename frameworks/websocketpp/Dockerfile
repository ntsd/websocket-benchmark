# Use Ubuntu as base image for better package availability
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libboost-all-dev \
    libasio-dev \
    nlohmann-json3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install websocketpp (header-only library)
RUN git clone https://github.com/zaphoyd/websocketpp.git /opt/websocketpp

# Set work directory
WORKDIR /app

# Copy source files
COPY . .

# Create build directory and build
RUN mkdir build && cd build \
    && cmake .. -DCMAKE_PREFIX_PATH=/opt/websocketpp \
    && make

# Expose port
EXPOSE 9001

# Run the server
CMD ["./build/websocketpp_server"]