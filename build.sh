#!/bin/bash
set -e

APP_NAME="curli"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
PACKAGE_NAME=github.com/trinhminhtriet/$APP_NAME

CURRENT_TAG_NAME="$(git describe --tags --abbrev=0)"
CURRENT_VERSION="${CURRENT_TAG_NAME//v/}"

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

# Create the new version.go content
VERSION_FILE_CONTENT="package internal

var (
\tVERSION = \"$VERSION\"
\tDATE    = \"$BUILD_DATE\"
)

"
echo -e "$VERSION_FILE_CONTENT" >internal/version.go

git add internal/version.go
git commit -m "Update version to $NEW_VERSION"
git tag -a $TAG_NAME -m "Tag version $TAG_NAME"
git push origin $TAG_NAME
git push origin $GIT_BRANCH

GIT_COMMIT=$(git rev-parse --short HEAD)

echo "New version: $NEW_VERSION"
echo "New tag name: $TAG_NAME"
echo "Git branch: $GIT_BRANCH"
echo "Build date: $BUILD_DATE"

export CGO_ENABLED=0
LDFLAGS="-s -w \
    -X \"$PACKAGE_NAME/internal.VERSION=$NEW_VERSION\" \
    -X \"$PACKAGE_NAME/internal.DATE=$BUILD_DATE\"\
"

mkdir -p dist
# GOOS=windows GOARCH=arm GOARM=5 go build -o dist/$APP_NAME -ldflags="$LDFLAGS" ./main.go
# go build -o dist/$APP_NAME -ldflags="$LDFLAGS" main.go

echo "Build completed with COMMIT=$GIT_COMMIT, date=$BUILD_DATE"
