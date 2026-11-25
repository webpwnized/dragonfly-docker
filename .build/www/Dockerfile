# ==============================================================================
# DRAGONFLY WWW DOCKERFILE (MINIMAL MULTI-STAGE)
# ==============================================================================
# Container image: webpwnized/dragonfly:www
#
# Build from the project root:
#   docker build --file .build/www/Dockerfile --tag webpwnized/dragonfly:www .
#
# Build with refreshed base images:
#   docker build --pull --file .build/www/Dockerfile --tag webpwnized/dragonfly:www .
#
# Run from the project root:
#   docker compose --file .build/docker-compose.yaml up --detach
#
# Testing:
#   docker compose --file .build/docker-compose.yaml up --detach
#
# Development:
#   docker compose -f .build/docker-compose.yaml run -d --rm --name dragonfly --service-ports --volume "$HOME/projects/dragonfly/dragonfly/src:/var/www/dragonfly:ro" www
#
# Stop the regular Compose service before starting the development container:
#   docker compose --file .build/docker-compose.yaml down
#
# Stop the development container:
#   docker stop dragonfly
#
# The development container is automatically removed when it stops because
# the development command includes --rm.
# ==============================================================================

# ==============================================================================
# STAGE 1: build-stage-1 (Application Fetcher)
# Purpose: Downloads source code via Git. Discarded entirely after build.
# ==============================================================================
FROM alpine:latest AS build-stage-1

# Install Git only in the application-fetching stage.
# A shallow clone downloads the current default-branch revision without
# downloading the complete repository history.
RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/webpwnized/dragonfly.git /tmp/dragonfly

# ==============================================================================
# STAGE 2: Minimal Hardened Runtime
# Purpose: Lightweight PHP runtime
# ==============================================================================
FROM php:8.5-cli-alpine AS build-stage-final

# Copy web files from Stage 1 into the document root.
# COPY defaults to root ownership. The non-root web process can read the
# application files without owning them or being able to modify them.
COPY --from=build-stage-1 /tmp/dragonfly/src /var/www/dragonfly

# Set the application's working directory.
WORKDIR /var/www/dragonfly

# Document the existing application port.
# Publishing the port to the host is handled by Docker or Compose.
EXPOSE 80

# Run the container as the non-root www-data user.
USER www-data

# Check whether PHP serves the existing health endpoint.
# The endpoint must return exactly "ok" followed by a newline.
#
# Use PHP itself so no additional HTTP client package is needed.
# The request timeout is shorter than Docker's health-check timeout.
#
# Dockerfile commands use ordinary PHP dollar signs.
# Compose health-check commands require escaped dollar signs instead.
#
# An unhealthy status does not automatically restart the container.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD php -r '$context = stream_context_create(["http" => ["timeout" => 2]]); $body = @file_get_contents("http://127.0.0.1/health.php", false, $context); exit($body === "ok\n" ? 0 : 1);'

# Start PHP's built-in web server on port 80, serving /var/www/dragonfly.
CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www/dragonfly"]