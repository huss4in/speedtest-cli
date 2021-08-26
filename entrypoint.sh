#!/bin/sh

case "$TARGETARCH" in
amd64) ARCH='x86_64' ;;
arm) ARCH='armhf' ;; arm64) ARCH='aarch64' ;;
386 | mips64le | ppc64le | riscv64 | s390x) ARCH='i386' ;;
*)
    echo >&2 "\nError: Unexpected Architecture {{$ARCH}}"
    exit 1
    ;;
esac

wget "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-$ARCH-linux.tgz" -qO- | tar zx -C /bin speedtest && speedtest $@
