#!/usr/bin/env bash
set -euo pipefail

VERSION_FILE=${1:-VERSION}
VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "::error::${VERSION_FILE} must contain MAJOR.MINOR.PATCH; found '$VERSION'"
  exit 1
fi

echo "Version: $VERSION"
