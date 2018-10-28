
DOCKER = docker

## Docker
## -----

docker-build: ## Build docker image
docker-build: docker-rmi
	$(DOCKER) build -t docker-robot-framework:latest .
	$(DOCKER) image prune -f

docker-rm: ## Remove all unused containers
docker-rm:
	$(DOCKER) container prune -f

docker-rmi: ## Remove all untagged images
docker-rmi: docker-rm
	$(DOCKER) image prune -f

## QA
## ------
tests-local: ## Run Robot Framework tests
tests-local:
	 $(DOCKER) network create tests-network
	 $(DOCKER) run --rm -d -p 4444:4444 -v /dev/shm:/dev/shm --network=tests-network --name node selenium/standalone-chrome:3
	 sleep 10
	 -$(DOCKER) run --rm -v ${PWD}/tests:/tests:ro -v ${PWD}/reports:/reports --network=tests-network docker-robot-framework robot --outputdir /reports RF
	 $(DOCKER) kill node
	 $(DOCKER) network rm tests-network

clean-tests-local: ## Clean local test environment
clean-tests-local:
	 -$(DOCKER) kill node
	 -$(DOCKER) network rm tests-network

.PHONY: tests-local clean-tests-local

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
