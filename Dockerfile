# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /build

# Copy go mod files first for caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o wise .

# Runtime stage
FROM alpine:3.21

# Install common tools the agent might need
RUN apk add --no-cache \
    bash \
    git \
    curl \
    jq

# Create config directory
RUN mkdir -p /etc/wise

# Copy binary and config
COPY --from=builder /build/wise /usr/local/bin/wise
COPY --from=builder /build/config.toml /etc/wise/config.toml

WORKDIR /work

ENTRYPOINT ["wise"]
