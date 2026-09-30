# ==============================================================================
# DRAGONFLY WWW DOCKERFILE (ULTRA-MINIMAL MULTI-STAGE)
# ==============================================================================
# Container image: webpwnized/dragonfly:www
# Build: docker build --file .build/www/Dockerfile --tag webpwnized/dragonfly:www .
# Run:   docker compose --file .build/docker-compose.yml up --detach
# ==============================================================================

# ==============================================================================
# STAGE 1: build-stage-1 (Application Fetcher)
# Purpose: Downloads source code via Git. Discarded entirely after build.
# ==============================================================================
FROM php:alpine AS build-stage-1

RUN apk add --no-cache git && \
    git clone https://github.com/webpwnized/dragonfly.git /tmp/dragonfly


# ==============================================================================
# STAGE 2: Minimal Hardened Runtime
# Purpose: Lightweight PHP runtime
# ==============================================================================
FROM php:8.2-alpine AS build-stage-final

# Install curl (required for Docker HEALTHCHECK)
RUN apk add --no-cache curl

# Copy web files from Stage 1 into document root
COPY --from=build-stage-1 --chown=www-data:www-data /tmp/dragonfly/src /var/www/dragonfly

WORKDIR /var/www/dragonfly

# Health check to verify application responds
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:80/ || exit 1

EXPOSE 80

# Run container as non-root www-data user
USER www-data

# Start PHP built-in web server on port 80 serving /var/www/dragonfly
CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www/dragonfly"]