#!/bin/bash

TAG=huss4in7/speedtest-cli

PLATFORMS=linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/mips64le,linux/ppc64le,linux/riscv64,linux/s390x

case "$1" in
"")
    # Build for all architectures
    docker buildx build . --tag $TAG --platform $PLATFORMS
    ;;
"--test" | "-t")

    printf "For faster tests, press ctrl+c to kill successful builds, and continue\n"
    IFS=',' read -ra platforms <<<"$PLATFORMS"
    len=${#platforms[@]}
    passed=0

    # Test for all architectures
    for i in "${!platforms[@]}"; do
        printf "\n\033[0;33mTest \033[0;36m$(($i + 1))\033[0;33m/$len: \033[0;35m${platforms[$i]}\033[0m\n"
        if docker buildx build . --tag test --platform "${platforms[$i]}" --load && docker run --rm -ti --init test; then
            passed=$(($passed + 1))
        fi
        printf "\n"
    done

    docker rmi test

    failed=$(($len - $passed))

    if [ $passed -ne 0 ]; then
        printf "\033[0;32m$passed\033[0m/\033[0;32m$len\033[0m Successful\n"
    fi

    if [ $failed -ne 0 ]; then
        printf "\033[0;31m$failed\033[0m/\033[0;32m$len\033[0m Failed\n"
    fi
    ;;

"--push" | "-p")
    # Build (if not cachesd) for all architectures, and Push
    docker buildx build . --tag $TAG --platform $PLATFORMS --push
    ;;
"--help" | "-h")
    printf "
Build, Test, and Deploy

USAGE:
    buildx.sh [OPTIONS]

OPTIONS:
    -t, --test                     Test on all architectures
    -p, --push                     Build (if not cachesd) for all architectures, and Push
    -h, --help                     Prints help information\n"
    ;;
*)
    echo "For help './buildx.sh --help'"
    ;;
esac
