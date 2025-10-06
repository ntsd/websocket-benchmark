benchmark-scenarios:
	k6 run ./benchmarks/scenarios.js

benchmark-connection:
	k6 run --vus 16 --duration 5s ./benchmarks/connection.js > ./results/connection.txt

benchmark-plain-async:
	k6 run --vus 16 --duration 5s ./benchmarks/plain-async.js > ./results/plain-async.txt

benchmark-plain-sync:
	k6 run --vus 16 --duration 5s ./benchmarks/plain-sync.js > ./results/plain-sync.txt

benchmark-json-async:
	k6 run --vus 16 --duration 5s ./benchmarks/json-async.js > ./results/json-async.txt

benchmark-json-sync:
	k6 run --vus 16 --duration 5s ./benchmarks/json-sync.js > ./results/json-sync.txt

benchmark-binary-async:
	k6 run --vus 16 --duration 5s ./benchmarks/binary-async.js > ./results/binary-async.txt

benchmark-binary-sync:
	k6 run --vus 16 --duration 5s ./benchmarks/binary-sync.js > ./results/binary-sync.txt

benchmark-all:
	@echo "Running comprehensive benchmarks for all frameworks..."
	@chmod +x websocket_benchmark.sh
	./websocket_benchmark.sh benchmark

benchmark-individual: \
	benchmark-connection \
	benchmark-plain-async \
	benchmark-plain-sync \
	benchmark-json-async \
	benchmark-json-sync \
	benchmark-binary-async \
	benchmark-binary-sync

extract-results:
	@echo "Extracting benchmark results..."
	@chmod +x websocket_benchmark.sh
	./websocket_benchmark.sh extract

benchmark-comprehensive:
	@echo "Running comprehensive WebSocket benchmark suite..."
	@chmod +x websocket_benchmark.sh
	./websocket_benchmark.sh both
