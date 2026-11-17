#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Builds the Hugo site that is deployed to a Cloudflare Worker.
#
# Only Hugo is installed: this project uses no Sass, Go modules, or npm
# packages. The version below is the one used locally, so bump both together.
#------------------------------------------------------------------------------

set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.170.0}"

# Reproducible dates in generated feeds and sitemaps.
export TZ=UTC

# Keep Hugo's file cache inside the project so Cloudflare's build cache can
# reuse it when enabled.
export HUGO_CACHEDIR="${PWD}/.cache/hugo"

build_temp_dir="$(mktemp -d)"
trap 'rm -rf "${build_temp_dir}"' EXIT INT TERM

main() {
  # Reuse a preinstalled Hugo (for example on GitHub Actions), otherwise
  # download the pinned release.
  if command -v hugo >/dev/null 2>&1; then
    echo "Using preinstalled Hugo: $(hugo version)"
  else
    echo "Installing Hugo ${HUGO_VERSION}..."
    curl -sfL --output-dir "${build_temp_dir}" -O \
      "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
    mkdir -p "${HOME}/.local/hugo"
    tar -C "${HOME}/.local/hugo" -xf "${build_temp_dir}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
    export PATH="${HOME}/.local/hugo:${PATH}"
    echo "Hugo: $(hugo version)"
  fi

  git config --global core.quotepath false

  # The theme is a git submodule.
  if [[ -f .gitmodules ]]; then
    echo "Initializing git submodules..."
    git submodule update --init --recursive
  fi

  echo "Building the site..."
  hugo build --gc --minify
}

main "$@"
