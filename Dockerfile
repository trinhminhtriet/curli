FROM golang:1.24-bullseye AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  upx-ucl

WORKDIR /build

COPY . .

# Build
RUN go mod download && go mod tidy
RUN CGO_ENABLED=0 go build \
  -o ./dist/curli \
  && upx-ucl --best --ultra-brute ./dist/curli

# final stage
FROM debian:bullseye-slim
RUN apt-get update && \
  apt-get install -y --no-install-recommends curl ca-certificates && \
  rm -rf /var/lib/apt/lists/*

ARG APPLICATION="curli"
ARG DESCRIPTION="A user-friendly curl interface combining HTTPie’s simplicity with curl’s full functionality and power."
ARG PACKAGE="trinhminhtriet/curli"

LABEL org.opencontainers.image.ref.name="${PACKAGE}" \
  org.opencontainers.image.authors="Triet Trinh <contact@trinhminhtriet.com>" \
  org.opencontainers.image.documentation="https://github.com/${PACKAGE}/README.md" \
  org.opencontainers.image.description="${DESCRIPTION}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.source="https://github.com/${PACKAGE}"

COPY --from=builder /build/dist/curli /bin/
WORKDIR /workdir
ENTRYPOINT ["/bin/curli"]
