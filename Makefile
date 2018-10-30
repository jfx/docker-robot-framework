
DOCKER = docker

IMAGE_NODE     = node:8-jessie
IMAGE_SELENIUM = selenium/standalone-chrome:3

PRIVATE_KEY = github-sign.key

UID := $(shell id -u)
GID := $(shell id -g)

## nodejs modules management
## -------------------------
yarn-install: ## Install nodejs modules with yarn
yarn-install: clean-node-modules
	$(DOCKER) run -t --rm -v ${PWD}:/node -w /node -u ${UID}:${GID} ${IMAGE_NODE} yarn --cache-folder /node/.node_cache install

yarn-outdated: ## Check outdated npm packages
yarn-outdated:
	$(DOCKER) run -t --rm -v ${PWD}:/node -w /node -u ${UID}:${GID} ${IMAGE_NODE} yarn --cache-folder /node/.node_cache outdated || true

yarn-upgrade: ## Upgrade packages
yarn-upgrade:
	$(DOCKER) run -t --rm -v ${PWD}:/node -w /node -u ${UID}:${GID} ${IMAGE_NODE} yarn --cache-folder /node/.node_cache upgrade

clean-node-modules: ## Remove node_modules directory
clean-node-modules:
	rm -rf .node_cache
	rm -rf node_modules

.PHONY: yarn-install yarn-outdated yarn-upgrade clean-node-modules

## Docker
## ------
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

docker-pull-images: ## Pull last docker images
docker-pull-images:
	$(DOCKER) pull ${IMAGE_NODE}
	$(DOCKER) pull ${IMAGE_SELENIUM}
	$(DOCKER) image prune -f

PHONY: docker-build docker-rm docker-rmi docker-pull-images

## QA
## --
tests-local: ## Run Robot Framework tests
tests-local:
	 $(DOCKER) network create tests-network
	 $(DOCKER) run --rm -d -p 4444:4444 -v /dev/shm:/dev/shm --network=tests-network --name selenium ${IMAGE_SELENIUM}
	 sleep 10
	 -$(DOCKER) run -t --rm -v ${PWD}/tests:/tests:ro -v ${PWD}/reports:/reports --network=tests-network docker-robot-framework robot --outputdir /reports RF
	 $(DOCKER) kill selenium
	 $(DOCKER) network rm tests-network

clean-tests-local: ## Clean local test environment
clean-tests-local:
	 -$(DOCKER) kill node
	 -$(DOCKER) network rm tests-network

.PHONY: tests-local clean-tests-local

## Admin
## -----
import-commit-key: ## Import key for sign commit
import-commit-key:
	mkdir -p .gnupg
	$(DOCKER) run -it --rm -v ${PWD}:/node -w /node -u ${UID}:${GID} ${IMAGE_NODE} gpg --homedir /node/.gnupg --import /node/${PRIVATE_KEY}

commit: ## Commit with Commitizen command line
commit:
	$(DOCKER) run -it --rm -v ${PWD}:/node -v ${PWD}/.node_cache:/.cache -w /node -u ${UID}:${GID} -e "GNUPGHOME=/node/.gnupg" ${IMAGE_NODE} yarn --cache-folder /node/.node_cache commit

.PHONY: commit

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
