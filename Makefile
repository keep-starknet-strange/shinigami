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

docker-build:
	$(eval COMMIT_SHA := $(shell git rev-parse --short HEAD))
	@echo "Building docker images with version $(COMMIT_SHA)"
	@echo "Building backend..."
	docker build . -f backend/Dockerfile -t "brandonjroberts/shinigami-backend:$(COMMIT_SHA)"

docker-push:
	$(eval COMMIT_SHA := $(shell git rev-parse --short HEAD))
	@echo "Pushing docker images with version $(COMMIT_SHA)"
	@echo "Pushing backend..."
	docker push "brandonjroberts/shinigami-backend:$(COMMIT_SHA)"
