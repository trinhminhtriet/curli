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
	-ldflags "-s -w -X '${PACKAGE}/internal.VERSION=${VERSION}' -X '${PACKAGE}/internal.DATE=${DATE}'" \
	-a -tags netgo -o dist/${NAME} main.go

build-and-link:
	go build \
		-ldflags "-s -w -X '${PACKAGE}/internal.VERSION=${VERSION}' -X '${PACKAGE}/internal.DATE=${DATE}'" \
	-a -tags netgo -o dist/${NAME} main.go
	ln -s ${PWD}/dist/${NAME} /usr/local/bin/${NAME}

release:
	goreleaser build --clean --snapshot --single-target

release-all:
	goreleaser build --clean --snapshot

link:
  	# Have to check verion of folder name _darwin_amd64_v1
	ln -sf ${PWD}/dist/${NAME}_darwin_amd64_v1/${NAME} /usr/local/bin/${NAME}
	which ${NAME}

clean:
	$(RM) -rf dist

.PHONY: default tidy build build-all build-and-link release
