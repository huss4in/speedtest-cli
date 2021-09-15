#!/bin/bash

set -ex

# Executable name
NAME=speedtest-c

# Go to the script's directory
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# Build binary builder
docker build -f Dockerfile.build -t $NAME:builder .

# Ensure build folder exists
mkdir build

# Delete old binaries and Dockerfiles
find build -type f '(' -name $NAME -o -name Dockerfile -o -name ca-certificates.crt ')' -delete

# Extract built binaries
docker run --rm $NAME:builder sh -c "find '(' -name $NAME -o -name ca-certificates.crt ')' -type f -print0 | xargs -0 tar --create" | tar --extract

# Create new Dockerfile from the template
find -name $NAME -type f -exec dirname "{}" ";" | xargs -n1 -i'{}' cp Dockerfile.template '{}/Dockerfile'

# Build and Test final docker image
docker build -t speedtest-cli:c-test build/amd64/*/ && docker run --rm speedtest-cli:c-test

# List all build binaries
echo && ls -lh */*/
