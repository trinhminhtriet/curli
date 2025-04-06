#!/bin/bash
set -e

APP_NAME="curli"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
PACKAGE_NAME=github.com/trinhminhtriet/$APP_NAME

CURRENT_VERSION="$(git describe --tags --abbrev=0)"

IFS='.' read -r major minor patch <<<"$CURRENT_VERSION"
echo "Current version: $CURRENT_VERSION"
new_patch=$((patch + 1))
NEW_VERSION="$major.$minor.$new_patch"

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ $GIT_BRANCH == "master" ]]; then
  TAG_NAME="v$NEW_VERSION"
else
  TAG_NAME="$NEW_VERSION-$GIT_BRANCH"
fi

# git commit -m "Update version to $NEW_VERSION"
git tag -a $TAG_NAME -m "Tag version $TAG_NAME"
git push origin $TAG_NAME
git push origin $GIT_BRANCH

GIT_COMMIT=$(git rev-parse --short HEAD)

echo "New version: $NEW_VERSION"
echo "Tag name: $TAG_NAME"
echo "Git branch: $GIT_BRANCH"
echo "Build date: $BUILD_DATE"

export CGO_ENABLED=0
LDFLAGS="-s -w \
    -X \"$PACKAGE_NAME.GIT_COMMIT=$GIT_COMMIT\" \
    -X \"$PACKAGE_NAME.VERSION=$NEW_VERSION\" \
    -X \"$PACKAGE_NAME.BUILD_DATE=$BUILD_DATE\"\
"

mkdir -p bin
# GOOS=windows GOARCH=arm GOARM=5 go build -o bin/$APP_NAME -ldflags="$LDFLAGS" ./main.go
go build -o bin/$APP_NAME -ldflags="$LDFLAGS" main.go

echo "Build completed with COMMIT=$GIT_COMMIT, VERSION=$GIT_COMMIT, date=$BUILD_DATE"
