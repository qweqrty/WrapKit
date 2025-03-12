#!/bin/bash

# Set up project root
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Paths and patterns
SOURCES_PATH="$PROJECT_ROOT"
TEMPLATE_PATH="$PROJECT_ROOT/Scripts/Sourcery/WeakRefVirtualProxy.stencil"
OUTPUT_DIR="$PROJECT_ROOT"

# Exclude paths (like Pods, .build, etc.)
EXCLUDED_DIRS=(".build" "Pods" "Carthage" ".git" "playgrounds")

# Construct the exclude args for Sourcery
EXCLUDE_ARGS=""
for EXCLUDED in "${EXCLUDED_DIRS[@]}"; do
    EXCLUDE_ARGS+="--exclude-sources $PROJECT_ROOT/$EXCLUDED "
done

# Delete all previously generated files
echo "Cleaning up previous WeakRefVirtualProxyGenerated files..."
find "$OUTPUT_DIR" -name '*WeakRefVirtualProxyGenerated.swift' -type f -delete

# Run Sourcery for _Flow.swift and _Presenter.swift files
echo "Running Sourcery for _Flow.swift and _Presenter.swift files..."

# Run Sourcery with CLI options to generate files in 'Generated' folder next to the source files
sourcery \
    --sources "$SOURCES_PATH" \
    --templates "$TEMPLATE_PATH" \
    --output "$PROJECT_ROOT/scripts/Sourcery/Derived" \
    $EXCLUDE_ARGS

echo "Sourcery completed successfully."
