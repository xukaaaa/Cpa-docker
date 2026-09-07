FROM golang:1.26 AS builder

WORKDIR /src

RUN apt-get update && apt-get install -y --no-install-recommends \
  git \
  ca-certificates \
  gcc \
  && update-ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 --branch dev \
  https://github.com/router-for-me/CLIProxyAPI.git .

RUN go mod download

RUN CGO_ENABLED=1 \
  GOOS=linux \
  go build \
  -ldflags="-s -w" \
  -o cli-proxy-api \
  ./cmd/server

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  bash \
  libgcc-s1 \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 user

RUN mkdir -p \
  /tmp/.cli-proxy-api \
  /tmp/logs \
  /home/user/app/plugins \
  /home/user/data/plugins \
  /home/user/data/plugins/codex-token-usage \
  /home/user/data/plugins/plugin-data \
  /home/user/.cli-proxy-api \
  && ln -sfn \
    /home/user/data/plugins \
    /home/user/.cli-proxy-api/plugins \
  && chmod -R u+rwX \
    /home/user/app \
    /home/user/data \
    /home/user/.cli-proxy-api \
    /tmp

USER user

ENV HOME=/home/user \
  PATH=/home/user/.local/bin:$PATH \
  CPA_TOKEN_USAGE_DIR=/home/user/data/plugins/codex-token-usage

WORKDIR /home/user/app

COPY --from=builder \
  --chown=user:user \
  /src/cli-proxy-api \
  /home/user/app/cli-proxy-api

COPY --chown=user:user \
  config.yaml \
  /home/user/app/config.yaml

COPY --chown=user:user \
  config.yaml \
  /home/user/app/config.example.yaml

EXPOSE 7860

CMD ["./cli-proxy-api", "--config", "/home/user/app/config.yaml", "--local-model"]
