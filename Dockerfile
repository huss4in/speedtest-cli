FROM alpine:edge

ARG TARGETARCH
ENV TARGETARCH=$TARGETARCH

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
