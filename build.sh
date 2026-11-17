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

# Prints the major.minor.patch of the Hugo on PATH, without build metadata
# such as "+extended".
installed_hugo_version() {
  command -v hugo >/dev/null 2>&1 || return 1
  hugo version 2>/dev/null | sed -n 's/^hugo v\([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p' | head -n 1
}

install_hugo() {
  echo "Installing Hugo ${HUGO_VERSION}..."
  curl -sfL --output-dir "${build_temp_dir}" -O \
    "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
  mkdir -p "${HOME}/.local/hugo"
  tar -C "${HOME}/.local/hugo" -xf "${build_temp_dir}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
  export PATH="${HOME}/.local/hugo:${PATH}"
}

main() {
  # Only reuse a preinstalled Hugo when it is exactly the pinned version.
  # Build images ship much older releases, which break the theme's templates.
  local installed
  if installed="$(installed_hugo_version)" && [[ "${installed}" == "${HUGO_VERSION}" ]]; then
    echo "Using preinstalled Hugo ${installed}"
  else
    if [[ -n "${installed}" ]]; then
      echo "Ignoring preinstalled Hugo ${installed}"
    fi
    install_hugo
    installed="$(installed_hugo_version)"
    if [[ "${installed}" != "${HUGO_VERSION}" ]]; then
      echo "ERROR: expected Hugo ${HUGO_VERSION}, got ${installed}" >&2
      exit 1
    fi
  fi
  echo "Hugo: $(hugo version)"

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
