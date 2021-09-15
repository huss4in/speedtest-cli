#!/bin/bash

TAG="huss4in7/speedtest-cli"
PLATFORMS="linux/386,linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6,linux/arm/v5,linux/mips64le,linux/ppc64le,linux/riscv64,linux/s390x"

ARCH="x86_64"

case "$1" in

'build' | '--build' | 'b' | '-b' | 'bp' | '-bp')

    if [[ "$1" == @('bp'|'-bp') || "$2" == @('push'|'--push'|'-p') ]]; then
        echo "Building and Pushing..."
        # Build (if not cached) for all architectures, and Push
        docker buildx build . --tag $TAG --platform $PLATFORMS --build-arg ARCH=$ARCH --push
    else
        echo "Building..."
        # Build (if not cached) for all architectures
        docker buildx build . --tag $TAG --platform $PLATFORMS --build-arg ARCH=$ARCH
    fi
    ;;

'test' | '--test' | 't' | '-t' | 'ta' | '-ta')

    if [[ "$1" == @('ta'|'-ta') || "$2" == @('all'|'--all'|'a'|'-a') ]]; then
        PLAT=$PLATFORMS
    elif [[ "$2" == '' ]]; then
        PLAT=$(echo $(uname --kernel-name) | tr '[:upper:]' '[:lower:]')/$(uname -m)
    else
        PLAT=$2
    fi

    a=$(echo $(uname --kernel-name) | tr '[:upper:]' '[:lower:]')

    echo "Testing for: $PLAT"

    IFS=',' read -ra platforms <<<"$PLAT"
    total_tests=${#platforms[@]}

    successful_builds=()
    successful_tests=()
    failed_builds=()
    failed_tests=()

    printf "For faster tests, press ctrl+c to kill successful builds, and continue\n"

    # Test for all architectures
    for i in "${!platforms[@]}"; do
        printf "\n\033[0;33mBuilding \033[0;36m$(($i + 1))\033[0;33m/$total_tests: \033[0;35m${platforms[$i]}\033[0m\n"

        if docker buildx build . --tag test --platform "${platforms[$i]}" --build-arg ARCH=$ARCH --load; then
            successful_builds+=(${platforms[$i]})

            printf "\n\033[0;33mTesting \033[0;34m$(($i + 1))\033[0;33m/$total_tests: \033[0;35m${platforms[$i]}\033[0m\n"
            if docker run -ti --rm --init --net host --name speedtest test; then
                successful_tests+=(${platforms[$i]})
            else
                failed_tests+=(${platforms[$i]})
            fi
        else
            failed_builds+=(${platforms[$i]})
        fi

    done

    printf "\n\n"

    successful_builds_count=${#successful_builds[@]}
    failed_builds_count=${#failed_builds[@]}
    successful_tests_count=${#successful_tests[@]}
    failed_tests_count=${#failed_tests[@]}

    if [ $successful_builds_count -ne 0 ]; then
        printf "\033[0;32m$successful_builds_count\033[0m/\033[0;32m$total_tests\033[0m Successful Build"
        if [ $successful_builds_count -ne 1 ]; then
            printf "s"
        fi

        printf " - ${successful_builds[0]}"
        for build in "${successful_builds[@]:1}"; do
            printf ", $build"
        done

        printf "\n"
    fi
    if [ $failed_builds_count -ne 0 ]; then
        printf "\033[0;31m$failed_builds_count\033[0m/\033[0;32m$total_tests\033[0m Failed Build"
        if [ $failed_builds_count -ne 1 ]; then
            printf "s"
        fi

        printf " - ${failed_builds[0]}"
        for build in "${failed_builds[@]:1}"; do
            printf ", $build"
        done

        printf "\n"
    fi

    if [ $successful_tests_count -ne 0 ]; then
        printf "\033[0;32m$successful_tests_count\033[0m/\033[0;32m$total_tests\033[0m Successful Test"
        if [ $successful_tests_count -ne 1 ]; then
            printf "s"
        fi

        printf " - ${successful_tests[0]}"
        for test in "${successful_tests[@]:1}"; do
            printf ", $test"
        done

        printf "\n"
    fi
    if [ $failed_tests_count -ne 0 ]; then
        printf "\033[0;31m$failed_tests_count\033[0m/\033[0;32m$total_tests\033[0m Failed/Skipped Test"
        if [ $failed_tests_count -ne 1 ]; then
            printf "s"
        fi

        printf " - ${failed_tests[0]}"
        for test in "${failed_tests[@]:1}"; do
            printf ", $test"
        done

        printf "\n"
    fi
    ;;

"help" | "--help" | "-h")
    printf "
⚒ Build, 🧪 Test, and 🚀 Deploy

USAGE:
    buildx.sh [OPTIONS]

OPTIONS:
    -t, --test <ARCH>   Test on <ARCH>/all architectures
    -p, --push          Build (if not cached) for all architectures, and Push
    -h, --help          Prints help information
"
    ;;
*)
    echo "For help './buildx.sh --help'"
    ;;
esac
