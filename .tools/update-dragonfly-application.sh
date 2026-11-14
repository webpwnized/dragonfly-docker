#!/bin/bash
set -euo pipefail

CONTAINER_NAME="www"
APP_PATH="/var/www/dragonfly"
REPO_URL="https://github.com/webpwnized/dragonfly.git"

usage() {
    cat <<'EOF'
Usage: update-dragonfly.sh [-b BRANCH | --branch BRANCH]
       update-dragonfly.sh [-h | --help]

Update Dragonfly in the running Docker container named www.

  -b, --branch BRANCH  Update from the specified Git branch.
                       With no branch specified, use the repository default.
  -h, --help           Show this help and exit.
EOF
}

handle_error() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

branch=""
case "${1:-}" in
    -h|--help)
        [[ $# -eq 1 ]] || handle_error "Use --help by itself."
        usage
        exit 0
        ;;
    -b|--branch)
        [[ $# -eq 2 && -n "$2" && "$2" != -* ]] ||
            handle_error "Specify one branch name. See --help."
        branch="$2"
        ;;
    "")
        [[ $# -eq 0 ]] || handle_error "See --help."
        ;;
    *)
        handle_error "Unknown argument: $1. See --help."
        ;;
esac

running=$(docker container inspect --format '{{.State.Running}}' "$CONTAINER_NAME") ||
    handle_error "Could not inspect container '$CONTAINER_NAME'."
[[ "$running" == "true" ]] ||
    handle_error "Container '$CONTAINER_NAME' is stopped."

docker exec -i -u root "$CONTAINER_NAME" /bin/bash -s -- \
    "$APP_PATH" "$REPO_URL" "$branch" <<'CONTAINER_SCRIPT'
set -euo pipefail

app_path="$1"
repo_url="$2"
branch="$3"

if ! command -v git >/dev/null 2>&1; then
    apt-get update
    apt-get install -y git
fi

# Stage beside the live directory so the final moves stay on one filesystem.
stage=$(mktemp -d -- "$(dirname -- "$app_path")/.dragonfly-update.XXXXXXXX")
backup="$stage/previous"
trap 'if [[ ! -e "$backup" ]]; then rm -rf -- "$stage"; fi' EXIT

clone_options=(--single-branch)
if [[ -n "$branch" ]]; then
    git check-ref-format "refs/heads/$branch"
    clone_options+=(--branch "$branch")
fi

git clone "${clone_options[@]}" -- "$repo_url" "$stage/repo"

# Git also accepts a tag for --branch. Require a branch checkout.
checked_out_branch=$(git -C "$stage/repo" symbolic-ref --quiet --short HEAD) ||
    { printf 'Error: The checkout is not a branch.\n' >&2; exit 1; }

[[ -f "$stage/repo/src/index.php" && -d "$app_path" && ! -L "$app_path" ]] ||
    { printf 'Error: Check the staged source and live application path.\n' >&2; exit 1; }

commit=$(git -C "$stage/repo" rev-parse --short HEAD)

# Retain the previous version for rollback after the browser smoke test.
mv -T -- "$app_path" "$backup"
if ! mv -T -- "$stage/repo/src" "$app_path"; then
    if ! mv -T -- "$backup" "$app_path"; then
        printf 'Error: Restore the previous application from %s\n' "$backup" >&2
    fi
    exit 1
fi

printf 'Updated Dragonfly from %s (%s).\n' "$checked_out_branch" "$commit"
printf 'Previous application retained at %s\n' "$backup"
CONTAINER_SCRIPT