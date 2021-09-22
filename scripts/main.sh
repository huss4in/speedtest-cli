#!/bin/bash

case "$1" in

"help" | "--help" | "h" | "-h")
    bash scripts/help.sh
    ;;

'make' | '--make' | 'm' | '-m' | 'mt' | '-mt')

    if [[ "$1" == @('mt'|'-mt') || "$2" == @('test'|'--test'|'-t') ]]; then
        bash scripts/make.sh test
    else
        bash scripts/make.sh
    fi

    ;;

'build' | '--build' | 'b' | '-b' | 'bp' | '-bp')

    if [[ "$1" == @('bp'|'-bp') || "$2" == @('push'|'--push'|'-p') ]]; then
        echo "Building and Pushing..."
        # Build (if not cached) for all architectures, and Push
        docker buildx build . --tag $DOCKER_TAG --platform $DOCKER_PLATFORMS --push
    else
        echo "Building..."
        # Build (if not cached) for all architectures
        docker buildx build . --tag $DOCKER_TAG --platform $DOCKER_PLATFORMS
    fi
    ;;

'test' | '--test' | 't' | '-t' | 'ta' | '-ta')

    if [[ "$1" == @('ta'|'-ta') || "$2" == @('all'|'--all'|'a'|'-a') ]]; then
        PLAT=$DOCKER_PLATFORMS
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

    successful_builds_count=${#successful_builds[@]}, failed_builds_count=${#failed_builds[@]}
    successful_tests_count=${#successful_tests[@]}, failed_tests_count=${#failed_tests[@]}

    if [ $successful_builds_count -ne 0 ]; then
        printf "\033[0;32m$successful_builds_count\033[0m/\033[0;32m$total_tests\033[0m Build"
        if [ $successful_builds_count -ne 1 ]; then
            printf "s"
        fi

        printf "\t✔ - ${successful_builds[0]}"
        for build in "${successful_builds[@]:1}"; do
            printf ", $build"
        done

        printf "\n"
    fi
    if [ $failed_builds_count -ne 0 ]; then
        printf "\033[0;31m$failed_builds_count\033[0m/\033[0;32m$total_tests\033[0m Build"
        if [ $failed_builds_count -ne 1 ]; then
            printf "s"
        fi

        printf "\t❌ - ${failed_builds[0]}"
        for build in "${failed_builds[@]:1}"; do
            printf ", $build"
        done

        printf "\n"
    fi

    if [ $successful_tests_count -ne 0 ]; then
        printf "\033[0;32m$successful_tests_count\033[0m/\033[0;32m$total_tests\033[0m Test"
        if [ $successful_tests_count -ne 1 ]; then
            printf "s"
        fi

        printf "\t✔ - ${successful_tests[0]}"
        for test in "${successful_tests[@]:1}"; do
            printf ", $test"
        done

        printf "\n"
    fi
    if [ $failed_tests_count -ne 0 ]; then
        printf "\033[0;31m$failed_tests_count\033[0m/\033[0;32m$total_tests\033[0m Test"
        if [ $failed_tests_count -ne 1 ]; then
            printf "s"
        fi

        printf "\t❌ - ${failed_tests[0]}"
        for test in "${failed_tests[@]:1}"; do
            printf ", $test"
        done

        printf "\n"
    fi
    ;;

*)
    echo "For help './buildx.sh --help'"
    ;;

esac
