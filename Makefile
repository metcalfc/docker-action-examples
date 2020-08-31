# BuildKit is a next generation container image builder. You can enable it using
# an environment variable or using the Engine config, see:
# https://docs.docker.com/develop/develop-images/build_enhancements/#to-enable-buildkit-builds
export DOCKER_BUILDKIT=1

GIT_TAG?=$(shell git describe --tags --match "v[0-9]*" 2> /dev/null)
ifeq ($(GIT_TAG),)
	GIT_TAG=edge
endif

# Docker image tagging:
HUB_USER?=${USER}
REPO?=$(shell basename ${PWD})
TAG?=${GIT_TAG}
DEV_IMAGE?=${REPO}:latest
PROD_IMAGE?=${HUB_USER}/${REPO}:${TAG}

# Local development happens here!
# This starts your application and bind mounts the source into the container so
# that changes are reflected in real time.
# Once you see the message "Running on http://0.0.0.0:5000/", open a Web browser at
# http://localhost:5000
.PHONY: dev
all: dev
dev:
	@COMPOSE_DOCKER_CLI_BUILD=1 docker-compose -f docker-compose.dev.yml up --build

# Run the unit tests.
.PHONY: build-test unit-test test
unit-test:
	@docker build --progress plain --target test ./app

test: unit-test

# Build a production image for the application.
.PHONY: build
build:
	@docker build --target prod --tag ${PROD_IMAGE} ./app

# Push the production image to a registry.
.PHONY: push
push: build
	@docker push ${PROD_IMAGE}

# Run the production image either via compose or run
.PHONY: deploy run
deploy: build
	@PROD_IMAGE=${PROD_IMAGE} docker-compose up -d

run: build
	@docker run -d -p 5000:5000 ${PROD_IMAGE}

# Remove the dev container, dev image, test image, and clear the builder cache.
.PHONY: clean
clean:
	@docker-compose -f docker-compose.dev.yml down
	@docker rmi ${DEV_IMAGE} || true
	@docker builder prune --force --filter type=exec.cachemount --filter=unused-for=24h
