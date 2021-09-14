FROM golang AS build

RUN apt update -y && apt install -y upx && update-ca-certificates

WORKDIR /go/src/app
COPY main.go go.mod ./

RUN touch /speedtest && chmod +x /speedtest

RUN CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags '-extldflags "-s -w -static"'

RUN upx --best --lzma speedtest-go

RUN echo $ARCH


# Copy the statically-linked binary into a scratch container.
FROM scratch

ARG ARCH
ENV ARCH=$ARCH

COPY --from=build /go/src/app/speedtest-go /speedtest /
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["/speedtest-go"]
