FROM debian:unstable-slim as build

ARG TARGETARCH

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y curl tar

WORKDIR /etc/ssl/certs

RUN case "$TARGETARCH" in \
    amd64) ARCH='x86_64';; \
    arm64/v8 | arm64) ARCH='aarch64' ;; arm) ARCH='armhf';; \
    386 | mips64le | ppc64le | riscv64 | s390x) ARCH='i386';; \
    *) echo >&2 "\nError: Unexpected Architecture {{$ARCH}}"; exit 1 ;; esac && \
    curl "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-$ARCH-linux.tgz" | tar zxv speedtest


FROM scratch

COPY --from=build /etc/ssl/certs/speedtest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/etc/ssl/certs/speedtest", "--accept-license"]
