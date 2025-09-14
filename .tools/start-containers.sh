#!/usr/bin/env bash
# Secure, resilient container launcher for dragonfly
# Goal: robust UX, clear diagnostics, no assumptions

set -Eeuo pipefail

# ---------- Logging ----------
ts() { date +"%Y-%m-%d %H:%M:%S%z"; }
info()  { printf "[%s] [INFO ] %s\n"  "$(ts)" "$*"; }
warn()  { printf "[%s] [WARN ] %s\n"  "$(ts)" "$*" >&2; }
error() { printf "[%s] [ERROR] %s\n" "$(ts)" "$*" >&2; }
die()   { error "$*"; exit 1; }

cleanup() { :; }
trap cleanup EXIT
trap 'error "Command failed at line $LINENO"; exit 1' ERR

# ---------- Defaults ----------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"   # parent of .tools
PROJECT_ROOT="$DEFAULT_ROOT"
COMPOSE_FILE=""
NO_BUILD=0
REBUILD=0
DRY_RUN=0
VERBOSE=0
BUILD_ARGS=()
IMAGE_TAG="webpwnized/dragonfly:www"
DOCKERFILE_REL=".build/www/Dockerfile"
COMPOSE_REL=".build/docker-compose.yml"

# ---------- Helpers ----------
run() {
  if (( DRY_RUN )); then
    printf "[%s] [DRYRUN] %q\n" "$(ts)" "$*"
  else
    if (( VERBOSE )); then set -x; fi
    "$@"
    if (( VERBOSE )); then set +x; fi
  fi
}

usage() {
  cat <<'USAGE'
Usage: start-containers.sh [options]

Options:
  --project-root PATH     Explicit project root (auto-detected if omitted)
  --compose PATH          Explicit docker-compose file (default: .build/docker-compose.yml under root)
  --no-build              Skip docker build (use existing image)
  --rebuild               Force rebuild (docker build --no-cache)
  --build-arg K=V         Add a build-arg (repeatable)
  --dry-run               Print actions without executing
  --verbose               Verbose command tracing
  -h, --help              Show this help

Examples:
  ./start-containers.sh
  ./start-containers.sh --rebuild --build-arg HTTP_PROXY=http://proxy:8080
  ./start-containers.sh --compose /abs/path/docker-compose.yml
USAGE
}

# ---------- Parse Args ----------
while (($#)); do
  case "$1" in
    --project-root) shift; PROJECT_ROOT="${1:-}"; [[ -n "$PROJECT_ROOT" ]] || die "--project-root requires a value";;
    --compose)      shift; COMPOSE_FILE="${1:-}"; [[ -n "$COMPOSE_FILE" ]] || die "--compose requires a value";;
    --no-build)     NO_BUILD=1;;
    --rebuild)      REBUILD=1;;
    --build-arg)    shift; [[ -n "${1:-}" ]] || die "--build-arg requires K=V"; BUILD_ARGS+=("--build-arg" "$1");;
    --dry-run)      DRY_RUN=1;;
    --verbose)      VERBOSE=1;;
    -h|--help)      usage; exit 0;;
    *)              usage; die "Unknown option: $1";;
  esac
  shift
done

# ---------- Environment Checks ----------
command -v docker >/dev/null 2>&1 || die "Docker not found. Install Docker Desktop/Engine and retry."

# Compose v2 (docker compose) or v1 (docker-compose)
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
else
  die "Docker Compose not found. Install Docker Compose v2 (preferred) or v1."
fi

# ---------- Detect Project Root if needed ----------
if [[ ! -d "$PROJECT_ROOT" ]]; then
  die "PROJECT_ROOT '$PROJECT_ROOT' does not exist."
fi

# If user didn’t pass --project-root, try Git to be extra safe
if [[ "$PROJECT_ROOT" == "$DEFAULT_ROOT" ]]; then
  if command -v git >/dev/null 2>&1; then
    if GIT_TOP=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null); then
      PROJECT_ROOT="$GIT_TOP"
      info "Detected project root via Git: $PROJECT_ROOT"
    else
      info "Git root not found; using default: $PROJECT_ROOT"
    fi
  fi
fi

# ---------- Resolve Paths ----------
DOCKERFILE_PATH="$PROJECT_ROOT/$DOCKERFILE_REL"
DEFAULT_COMPOSE_PATH="$PROJECT_ROOT/$COMPOSE_REL"

if [[ -z "$COMPOSE_FILE" ]]; then
  COMPOSE_FILE="$DEFAULT_COMPOSE_PATH"
fi

# ---------- Validate Layout ----------
[[ -f "$DOCKERFILE_PATH" ]] || {
  warn "Missing Dockerfile at: $DOCKERFILE_PATH"
  warn "Tip: Ensure you run in the project that contains '.build/www/Dockerfile'."
  die  "You ran from: $(pwd). Consider: --project-root '$PROJECT_ROOT' or move to repo root."
}

[[ -f "$COMPOSE_FILE" ]] || {
  warn "Missing compose file at: $COMPOSE_FILE"
  warn "Tip: The repo expects '.build/docker-compose.yml' under the project root."
  die  "Provide a valid file with --compose PATH."
}

# ---------- Show Plan ----------
info "Using:"
info "  Project Root : $PROJECT_ROOT"
info "  Dockerfile   : $DOCKERFILE_PATH"
info "  Compose File : $COMPOSE_FILE"
info "  Image Tag    : $IMAGE_TAG"
if (( NO_BUILD )); then info "  Build        : skipped (--no-build)"; fi
if (( REBUILD )); then info "  Build        : forced rebuild (--no-cache)"; fi
if (( DRY_RUN )); then info "  Mode         : DRY RUN (no changes applied)"; fi

# ---------- Build (optional) ----------
if (( NO_BUILD == 0 )); then
  info "Building image…"
  build_cmd=(docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG")
  if (( REBUILD )); then build_cmd+=(--no-cache); fi
  build_cmd+=("${BUILD_ARGS[@]}" "$PROJECT_ROOT")
  run "${build_cmd[@]}"
else
  info "Skipping build per --no-build; assuming image '$IMAGE_TAG' exists."
fi

# ---------- Up Containers ----------
info "Starting containers…"
run "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" up -d

# ---------- Health Checks (optional but helpful) ----------
info "Listing running services for quick verification:"
run "${COMPOSE_CMD[@" ]}" -f "$COMPOSE_FILE" ps

info "Success. Containers are up."
