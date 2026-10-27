# syntax=docker/dockerfile:1.28.0@sha256:bb22d9815c728170f72750f4e5b0d672e06176142e1d602c7e66c050100b7e5b

# Build the go application into a binary
FROM golang:alpine AS builder
RUN apk --update add ca-certificates
WORKDIR /app
COPY . ./
RUN go mod tidy -diff
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gatus .

# Run Tests inside docker image if you don't have a configured go environment
#RUN apk update && apk add --virtual build-dependencies build-base gcc
#RUN go test ./... -mod vendor

# Run the binary on an empty container
FROM scratch
COPY --from=builder /app/gatus .
COPY --from=builder /app/config.yaml ./config/config.yaml
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV GATUS_CONFIG_PATH=""
ENV GATUS_LOG_LEVEL="INFO"
ENV PORT="8080"
EXPOSE ${PORT}
ENTRYPOINT ["/gatus"]
