#!/bin/bash

# Start by assuming the script is run from somewhere inside the project directory
# This command goes up the directory tree and finds the directory containing .swiftlint.yml
PROJECT_ROOT=$(git rev-parse --show-toplevel)

if test -d "/opt/homebrew/bin/"; then
  PATH="/opt/homebrew/bin/:${PATH}"
fi

export PATH

if which swiftlint >/dev/null; then
  # Run SwiftLint with the specified configuration file and directory to lint
  swiftlint --config "$PROJECT_ROOT/.swiftlint.yml"
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
