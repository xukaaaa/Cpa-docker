# Cpa-docker

Docker deployment files for running `eceasy/cli-proxy-api:latest`.

## Deploy

1. Copy environment template:
   - `cp .env.example .env`
2. Fill required application environment variables in `.env`:
   - `MANAGEMENT_PASSWORD`
   - `PGSTORE_DSN`
3. Start service:
   - `docker compose up -d`

## Service

- Image: `eceasy/cli-proxy-api:latest`
- Default port mapping: `3000:3000` (override with `PORT` in `.env`)