#!/bin/bash

# Get project root path
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/utils/logger.sh"

check_required_tools() {
    local tools=("swiftc" "git" "xcpretty")
    local missing=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -eq 0 ]; then
        log_success "All required tools are available"
        return 0
    else
        log_error "Missing required tools: ${missing[*]}"
        return 1
    fi
}

init_environment() {
    # Create required directories
    mkdir -p "$PROJECT_ROOT"/{build,cache,logs,reports}
    
    # Load configuration
    if [ -f "$PROJECT_ROOT/configs/project_config.sh" ]; then
        source "$PROJECT_ROOT/configs/project_config.sh"
    else
        log_error "Configuration file not found"
        exit 1
    fi
    
    # Initialize logging
    export LOG_DIR="$PROJECT_ROOT/logs"
    export LOG_FILE="$LOG_DIR/build_$(date +%Y%m%d_%H%M%S).log"
    
    log_info "Environment initialized"
}

validate_environment() {
    if [ ! -d "$PROJECT_DIR" ]; then
        log_error "Project directory not found: $PROJECT_DIR"
        return 1
    fi

    if [ ! -f "$PROJECT_DIR/$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
        log_error "Xcode project file not found"
        return 1
    fi

    return 0
}
