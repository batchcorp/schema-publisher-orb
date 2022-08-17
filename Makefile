VERSION ?= $(shell git rev-parse --short HEAD)
SERVICE = publish

GO = CGO_ENABLED=$(CGO_ENABLED) go
CGO_ENABLED ?= 0
GO_BUILD_FLAGS = -ldflags "-X main.version=${VERSION}"

# Pattern #1 example: "example : description = Description for example target"
# Pattern #2 example: "### Example separator text
help: HELP_SCRIPT = \
	if (/^([a-zA-Z0-9-\.\/]+).*?: description\s*=\s*(.+)/) { \
		printf "\033[34m%-40s\033[0m %s\n", $$1, $$2 \
	} elsif(/^\#\#\#\s*(.+)/) { \
		printf "\033[33m>> %s\033[0m\n", $$1 \
	}

.PHONY: help
help:
	@perl -ne '$(HELP_SCRIPT)' $(MAKEFILE_LIST)

### Build

.PHONY: build
build: description = Build all
build: clean build/linux build/darwin

.PHONY: build/linux
build/linux: description = Build linux
build/linux: clean
	GOOS=linux GOARCH=amd64 $(GO) build $(GO_BUILD_FLAGS) -o ./publish-linux ./publish/*.go

.PHONY: build/darwin
build/darwin: description = Build darwin
build/darwin: clean
	GOOS=darwin GOARCH=amd64 $(GO) build $(GO_BUILD_FLAGS) -o ./publish-darwin ./publish/*.go

.PHONY: clean
clean: description = Remove existing build artifacts
clean:
	$(RM) ./src/scripts/$(SERVICE)-*

### Docker

.PHONY: docker/build
docker/build: description = Build docker image
docker/build:
	docker build -t batchcorp/schema-publisher-orb:$(VERSION) \
	-t batchcorp/schema-publisher-orb:latest \
	-f ./Dockerfile .

PHONY: docker/push
docker/push: description = Push local docker image
docker/push:
	docker push batchcorp/schema-publisher-orb:$(VERSION) && \
	docker push batchcorp/schema-publisher-orb:latest