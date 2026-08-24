FROM golang:1.24 AS builder

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /out/fiddle-test .
RUN go list -m -f '{{.Path}} {{.Version}}' all > /out/modules.txt

FROM alpine:3.20
COPY --from=builder /out/fiddle-test /usr/local/bin/fiddle-test
COPY --from=builder /out/modules.txt /modules.txt
ENTRYPOINT ["/usr/local/bin/fiddle-test"]
