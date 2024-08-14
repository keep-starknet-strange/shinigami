build: build-cairo
test: test-cairo test-core

build-cairo:
	@echo "Building cairo code..."
	scarb build

test-cairo:
	@echo "Testing cairo code..."
	scarb test

test-core:
	@echo "Running bitcoin-core tests..."
	@./tests/run-core-tests.sh 0 1207
