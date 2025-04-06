NAME    := curli
PACKAGE := github.com/trinhminhtriet/$(NAME)
DATE    :=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT     := $(shell [ -d .git ] && git rev-parse --short HEAD)
VERSION := $(shell git describe --tags)

default: build

upgrade:
	go get -u && go mod tidy

build:
	CGO_ENABLED=0 go build \
	-ldflags "-s -w -X '${PACKAGE}/VERSION=${VERSION}' -X '${PACKAGE}/DATE=${DATE}'" \
	-a -tags netgo -o bin/${NAME} main.go

build-and-link:
	go build \
		-ldflags "-s -w -X '${PACKAGE}/VERSION=${VERSION}' -X '${PACKAGE}/DATE=${DATE}'" \
	-a -tags netgo -o bin/${NAME} main.go
	ln -s ${PWD}/bin/${NAME} /usr/local/bin/${NAME}

release:
	git tag ${VERSION} && git push origin ${VERSION}

.PHONY: default tidy build build-all build-and-link release
