#!/bin/bash

# Project Configuration
export PROJECT_DIR=""
export PROJECT_NAME=""
export BUILD_CONFIGURATION=""
export SCHEME_NAME="$PROJECT_NAME"

# Build paths
export BUILD_DIR="$PROJECT_DIR/build"
export ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
export EXPORT_PATH="$BUILD_DIR/Export"

# Cache settings
export CACHE_DIR="$PROJECT_DIR/cache"
export MAX_CACHE_SIZE=1000

# Compiler settings
export SWIFT_VERSION="5.0"
export DEPLOYMENT_TARGET="14.0"

# Build options
export ENABLE_PARALLEL_BUILD=true
export MAX_CONCURRENT_TASKS=4

# Development team settings (auto-detected)
export DEVELOPMENT_TEAM="$(security find-identity -v -p codesigning | grep "iPhone Developer" | head -n 1 | cut -d '"' -f 2)"
