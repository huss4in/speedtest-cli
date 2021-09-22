#!/bin/bash

set -e

case "$1" in

"test")
    args=${@:3}

    printf "\n${YEL}Building${END}: ${BLN}${CYN}$DOCKER_TAG:test${END}\n"
    {
        docker build -t $DOCKER_TAG:test ./src -f Dockerfiles/Dockerfile.builder
    }

    printf "\n${YEL}Testing${END}: ${BLD}${BLU}$DOCKER_TAG:test${END} $args\n"
    {
        # docker run -ti --rm --init --net=host -v "$PWD/src":/usr/src/speedtest $DOCKER_TAG:test $args
        docker run -ti --rm --init --net=host $DOCKER_TAG:test $args
    }
    ;;

*)
    printf "\n${YEL}Building${END}: ${BLN}${CYN}$DOCKER_TAG:c-builder${END}\n"
    {
        docker build -t $DOCKER_TAG:builder ./src -f Dockerfiles/Dockerfile.builder
    }

    printf "\n${YEL}Removing${END}: ${LRE}old artifacts${END}\n"
    {
        rm -rfv $ARTIFACTS_FOLDER
    }

    printf "\n${YEL}Extracting${END}: ${GRN}new artifacts${END} from ${BLD}${UND}${BLU}$DOCKER_TAG-c:builder${END}\n"
    {
        docker run --rm $DOCKER_TAG:builder sh -c "cd /usr/src/speedtest && find $ARTIFACTS_FOLDER -type f -print0 | xargs -0 tar --create" | tar --extract

        exa -alT $ARTIFACTS_FOLDER/*
    }

    printf "\n${YEL}Creating${END}: ${BLD}${CYN}Dockerfile${END}s from ${BLD}${UND}${BLU}Dockerfile.template${END}\n"
    {
        find $ARTIFACTS_FOLDER -name $TARGET_SPT_NAME -type f -exec dirname {} \; | xargs -n1 -i{} cp Dockerfiles/Dockerfile.template {}/Dockerfile
        exa -al $ARTIFACTS_FOLDER/*/Dockerfile
    }

    printf "\n${YEL}Artifacts Built${END}: Do you want to test it? (y/N) "

    read answer

    case "$answer" in

    "yes" | "y")
        printf "\n${YEL}Building${END}: ${BLN}${CYN}$DOCKER_TAG:test${END}\n"
        {
            docker build -t $DOCKER_TAG:c-test $ARTIFACTS_FOLDER/amd64
        }

        printf "\n${YEL}Testing${END}: ${BLD}${BLU}$DOCKER_TAG:test${END}\n"
        {
            docker run -ti --rm --init --net=host $DOCKER_TAG:c-test
        }
        ;;

    "" | "*") ;;

    esac
    ;;

esac
