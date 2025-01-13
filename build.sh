#!/bin/bash

set -e

PACKAGE_NAME=github.com/trinhminhtriet/curli

COMMIT=$(git rev-parse --short HEAD)
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

CURRENT_VERSION="$(git describe --tags --abbrev=0 | tr -d '\n')"
VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2"."$3+1}')

echo "Current version: $CURRENT_VERSION"
echo "Next version: $VERSION"

export CGO_ENABLED=0

LDFLAGS="-s -w \
    -X \"$PACKAGE_NAME.GIT_COMMIT=$GIT_COMMIT\" \
    -X \"$PACKAGE_NAME.VERSION=$VERSION\" \
    -X \"$PACKAGE_NAME.BUILD_DATE=$BUILD_DATE\"\
"

mkdir -p bin
GOOS=windows GOARCH=arm GOARM=5 go build -o bin/curli -ldflags="$LDFLAGS" ./main.go

echo "Build completed with COMMIT=$COMMIT, VERSION=$VERSION, date=$DATE"
