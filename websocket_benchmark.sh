#!/bin/bash

# Comprehensive WebSocket Benchmark Suite
# Combines benchmarking, result extraction, and parsing in one script
# Usage: ./websocket_benchmark.sh [benchmark|extract|both]

set -e

# Configuration
FRAMEWORKS=(
    "tokio-tungstenite"
    "fasthttp-websocket" 
    "gorilla-websocket"
    "uwebsocket-js"
    "websocketpp"
    "sib"
)

BUN_FRAMEWORKS=(
    "bun-websocket-plain"
    "bun-websocket-json"
    "bun-websocket-binary"
)

TESTS=(
    "connection"
    "plain-sync"
    "plain-async"
    "json-sync"
    "json-async"
    "binary-sync"
    "binary-async"
)

RESULTS_DIR="./results/vus-16"
VUS=16
DURATION="5s"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to run benchmark for a framework and test
run_benchmark() {
    local framework=$1
    local test=$2
    local output_file="$RESULTS_DIR/$framework/$test.txt"
    
    # Create framework directory
    mkdir -p "$RESULTS_DIR/$framework"
    
    print_status "$BLUE" "Testing $framework with $test..."
    
    # Stop any running containers
    docker compose down > /dev/null 2>&1 || true
    
    # Start the framework
    docker compose up -d "$framework" > /dev/null 2>&1
    
    # Wait for container to be ready
    sleep 3
    
    # Run the benchmark
    if k6 run --vus "$VUS" --duration "$DURATION" "./benchmarks/${test}.js" > "$output_file" 2>&1; then
        print_status "$GREEN" "✓ $framework $test completed"
    else
        print_status "$RED" "✗ $framework $test failed"
    fi
    
    # Stop the container
    docker compose down > /dev/null 2>&1 || true
    sleep 2
}

# Function to run all benchmarks
run_all_benchmarks() {
    print_status "$YELLOW" "=== Starting comprehensive WebSocket benchmarks ==="
    echo "Frameworks: ${FRAMEWORKS[*]} + bun variants"
    echo "Tests: ${TESTS[*]}"
    echo "Configuration: $VUS VUs, $DURATION duration, 2 CPU cores, 1GB memory"
    echo ""

    # Create results directory
    mkdir -p "$RESULTS_DIR"

    # Test regular frameworks
    for framework in "${FRAMEWORKS[@]}"; do
        echo ""
        print_status "$YELLOW" "=== Testing $framework ==="
        
        for test in "${TESTS[@]}"; do
            run_benchmark "$framework" "$test"
        done
    done

    # Special handling for Bun WebSocket (separate containers for different endpoints)
    echo ""
    print_status "$YELLOW" "=== Testing bun-websocket ==="

    # Create bun-websocket results directory
    mkdir -p "$RESULTS_DIR/bun-websocket"

    # Connection test (can use any bun variant)
    print_status "$BLUE" "Testing bun-websocket with connection..."
    docker compose down > /dev/null 2>&1 || true
    docker compose up -d bun-websocket-plain > /dev/null 2>&1
    sleep 3
    if k6 run --vus "$VUS" --duration "$DURATION" "./benchmarks/connection.js" > "$RESULTS_DIR/bun-websocket/connection.txt" 2>&1; then
        print_status "$GREEN" "✓ bun-websocket connection completed"
    else
        print_status "$RED" "✗ bun-websocket connection failed"
    fi
    docker compose down > /dev/null 2>&1 || true

    # Plain tests
    for test in "plain-sync" "plain-async"; do
        print_status "$BLUE" "Testing bun-websocket with $test..."
        docker compose up -d bun-websocket-plain > /dev/null 2>&1
        sleep 3
        if k6 run --vus "$VUS" --duration "$DURATION" "./benchmarks/${test}.js" > "$RESULTS_DIR/bun-websocket/${test}.txt" 2>&1; then
            print_status "$GREEN" "✓ bun-websocket $test completed"
        else
            print_status "$RED" "✗ bun-websocket $test failed"
        fi
        docker compose down > /dev/null 2>&1 || true
        sleep 2
    done

    # JSON tests
    for test in "json-sync" "json-async"; do
        print_status "$BLUE" "Testing bun-websocket with $test..."
        docker compose up -d bun-websocket-json > /dev/null 2>&1
        sleep 3
        if k6 run --vus "$VUS" --duration "$DURATION" "./benchmarks/${test}.js" > "$RESULTS_DIR/bun-websocket/${test}.txt" 2>&1; then
            print_status "$GREEN" "✓ bun-websocket $test completed"
        else
            print_status "$RED" "✗ bun-websocket $test failed"
        fi
        docker compose down > /dev/null 2>&1 || true
        sleep 2
    done

    # Binary tests
    for test in "binary-sync" "binary-async"; do
        print_status "$BLUE" "Testing bun-websocket with $test..."
        docker compose up -d bun-websocket-binary > /dev/null 2>&1
        sleep 3
        if k6 run --vus "$VUS" --duration "$DURATION" "./benchmarks/${test}.js" > "$RESULTS_DIR/bun-websocket/${test}.txt" 2>&1; then
            print_status "$GREEN" "✓ bun-websocket $test completed"
        else
            print_status "$RED" "✗ bun-websocket $test failed"
        fi
        docker compose down > /dev/null 2>&1 || true
        sleep 2
    done

    echo ""
    print_status "$GREEN" "=== Benchmarking completed! ==="
    echo "Results saved in $RESULTS_DIR/"
}

# Function to extract metric value from k6 results
extract_metric() {
    local file="$1"
    local metric_name="$2"
    
    if [[ -f "$file" ]]; then
        # Extract the rate (third column) after the metric name
        grep "^    $metric_name" "$file" | awk '{print $3}' | head -1
    else
        echo "N/A"
    fi
}

# Function to extract ws_connecting details
extract_connecting_details() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        # Extract everything after ws_connecting.:
        grep "^    ws_connecting" "$file" | sed 's/^.*ws_connecting.*: //' | head -1
    else
        echo "N/A"
    fi
}

# Function to sort frameworks by performance
sort_frameworks_by_metric() {
    local frameworks_list="$1"
    local metric_type=$2
    local test_file=$3
    
    local temp_file=$(mktemp)
    
    # Extract metrics and create sortable list
    for fw in $frameworks_list; do
        local file="$RESULTS_DIR/$fw/$test_file"
        local value=$(extract_metric "$file" "$metric_type")
        
        # Convert to number for sorting (remove /s and other non-numeric chars)
        local numeric_value=$(echo "$value" | sed 's/[^0-9.]//g')
        
        if [[ "$numeric_value" =~ ^[0-9]*\.?[0-9]+$ ]]; then
            echo "$numeric_value $fw" >> "$temp_file"
        else
            echo "0 $fw" >> "$temp_file"
        fi
    done
    
    # Sort by numeric value (descending) and extract framework names
    sort -nr "$temp_file" | awk '{print $2}'
    rm "$temp_file"
}

# Function to extract and display results
extract_results() {
    print_status "$YELLOW" "Parsing WebSocket Benchmark Results ($VUS VUs, $DURATION duration, 2 CPU cores)"
    echo "==============================================================="
    echo

    # Get list of frameworks that have results
    local frameworks=()
    for dir in "$RESULTS_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            fw=$(basename "$dir")
            frameworks+=("$fw")
        fi
    done

    if [[ ${#frameworks[@]} -eq 0 ]]; then
        print_status "$RED" "No benchmark results found in $RESULTS_DIR"
        return 1
    fi

    print_status "$BLUE" "Available frameworks: ${frameworks[*]}"
    echo

    # Connection Results (sorted by performance)
    echo "### Connection Method $VUS VUs Result"
    echo
    echo "| Framework | ws_sessions | ws_connecting |"
    echo "|-----------|-------------|---------------|"

    # Sort frameworks by connection performance
    local sorted_frameworks=$(sort_frameworks_by_metric "${frameworks[*]}" "ws_sessions" "connection.txt")

    for fw in $sorted_frameworks; do
        local file="$RESULTS_DIR/$fw/connection.txt"
        local sessions=$(extract_metric "$file" "ws_sessions")
        local connecting=$(extract_connecting_details "$file")
        echo "| $fw | $sessions | $connecting |"
    done

    echo

    # JSON Sync Results (sorted by performance)
    echo "### JSON Sync Method $VUS VUs Result"
    echo
    echo "| Framework | ws_msgs_received |"
    echo "|-----------|------------------|"

    local sorted_frameworks=$(sort_frameworks_by_metric "${frameworks[*]}" "ws_msgs_received" "json-sync.txt")

    for fw in $sorted_frameworks; do
        local file="$RESULTS_DIR/$fw/json-sync.txt"
        local msgs=$(extract_metric "$file" "ws_msgs_received")
        echo "| $fw | $msgs |"
    done

    echo

    # JSON Async Results (sorted by performance)
    echo "### JSON Async Method $VUS VUs Result" 
    echo
    echo "| Framework | ws_msgs_received |"
    echo "|-----------|------------------|"

    local sorted_frameworks=$(sort_frameworks_by_metric "${frameworks[*]}" "ws_msgs_received" "json-async.txt")

    for fw in $sorted_frameworks; do
        local file="$RESULTS_DIR/$fw/json-async.txt"
        local msgs=$(extract_metric "$file" "ws_msgs_received")
        echo "| $fw | $msgs |"
    done

    echo

    # Binary Sync Results (sorted by performance)
    echo "### Binary Sync Method $VUS VUs Result"
    echo
    echo "| Framework | ws_msgs_received |"
    echo "|-----------|------------------|"

    local sorted_frameworks=$(sort_frameworks_by_metric "${frameworks[*]}" "ws_msgs_received" "binary-sync.txt")

    for fw in $sorted_frameworks; do
        local file="$RESULTS_DIR/$fw/binary-sync.txt"
        local msgs=$(extract_metric "$file" "ws_msgs_received")
        echo "| $fw | $msgs |"
    done

    echo

    # Binary Async Results (sorted by performance)
    echo "### Binary Async Method $VUS VUs Result"
    echo
    echo "| Framework | ws_msgs_received |"
    echo "|-----------|------------------|"

    local sorted_frameworks=$(sort_frameworks_by_metric "${frameworks[*]}" "ws_msgs_received" "binary-async.txt")

    for fw in $sorted_frameworks; do
        local file="$RESULTS_DIR/$fw/binary-async.txt"  
        local msgs=$(extract_metric "$file" "ws_msgs_received")
        echo "| $fw | $msgs |"
    done

    echo
    print_status "$GREEN" "Results extraction completed!"
}

# Function to display usage
show_usage() {
    echo "WebSocket Benchmark Suite - Comprehensive testing and analysis tool"
    echo ""
    echo "Usage: $0 [benchmark|extract|both|help]"
    echo ""
    echo "Commands:"
    echo "  benchmark  - Run benchmarks for all frameworks"
    echo "  extract    - Extract and display results from existing benchmark data"
    echo "  both       - Run benchmarks and then extract results (default)"
    echo "  help       - Show this help message"
    echo ""
    echo "Configuration:"
    echo "  VUs: $VUS"
    echo "  Duration: $DURATION"
    echo "  Results directory: $RESULTS_DIR"
    echo ""
    echo "Examples:"
    echo "  $0                 # Run full benchmark suite and extract results"
    echo "  $0 benchmark       # Only run benchmarks"
    echo "  $0 extract         # Only extract results from existing data"
}

# Main script logic
main() {
    local command=${1:-both}
    
    case "$command" in
        "benchmark")
            run_all_benchmarks
            ;;
        "extract")
            extract_results
            ;;
        "both")
            run_all_benchmarks
            echo ""
            extract_results
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            echo "Unknown command: $command"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi