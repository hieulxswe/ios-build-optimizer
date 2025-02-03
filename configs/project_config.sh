#!/bin/bash

# Project Information
export PROJECT_DIR=""
export PROJECT_NAME=""
export BUILD_CONFIGURATION=""
export SCHEME_NAME="$PROJECT_NAME"

# Build Settings
export SWIFT_VERSION="5.0"
export DEPLOYMENT_TARGET="14.0"
export ENABLE_PARALLEL_BUILD=true
export MAX_CONCURRENT_TASKS=4

# Directory Paths
export BUILD_DIR="${PROJECT_ROOT}/build"
export CACHE_DIR="${PROJECT_ROOT}/cache"
export REPORTS_DIR="${PROJECT_ROOT}/reports"
export LOG_DIR="${PROJECT_ROOT}/logs"

# Build phases
export CLEAN_BUILD=false
export ENABLE_TESTS=false
export ENABLE_DOCUMENTATION=false

# Analysis Settings
export MIN_TEST_COVERAGE=80
export MAX_FILE_SIZE=400
export MAX_COMPLEXITY=10
export MAX_IMPORTS=10

# Simple validation to ensure project exists
validate_config() {
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "Error: Project directory not found: $PROJECT_DIR"
        return 1
    fi
    return 0
}

# Initialize directories
init_directories() {
    mkdir -p "$BUILD_DIR" "$CACHE_DIR" "$REPORTS_DIR" "$LOG_DIR"
    chmod -R 755 "$PROJECT_ROOT"
}
