#!/bin/bash

# Environment Setup and Validation
init_environment() {
    log_info "Initializing environment..."
    
    # Set up project root
    export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    # Load configurations
    source "$PROJECT_ROOT/configs/project_config.sh"
    
    # Create required directories
    create_directories
    
    # Initialize logging
    init_logging
    
    # Set up environment variables
    setup_environment_variables
    
    # Validate environment
    validate_environment
}

create_directories() {
    mkdir -p "$BUILD_DIR" "$CACHE_DIR" "$REPORTS_DIR" "$LOG_DIR"
    chmod -R 755 "$PROJECT_ROOT"
}

init_logging() {
    export LOG_FILE="$LOG_DIR/build_$(date +%Y%m%d_%H%M%S).log"
    touch "$LOG_FILE"
}

setup_environment_variables() {
    # Xcode related
    export DEVELOPER_DIR="$(xcode-select -p)"
    export SDKROOT="$(xcrun --show-sdk-path --sdk iphoneos)"
    
    # Build related
    export BUILD_NUMBER=$(date +%Y%m%d%H%M)
    export CONFIGURATION="$BUILD_CONFIGURATION"
    
    # Path related
    export PATH="$DEVELOPER_DIR/usr/bin:$PATH"
}

validate_environment() {
    log_info "Validating environment..."
    
    # Check required tools
    check_required_tools || exit 1
    
    # Validate project directory
    if [ ! -d "$PROJECT_DIR" ]; then
        log_error "Project directory not found: $PROJECT_DIR"
        exit 1
    fi
    
    # Check Xcode project
    if [ ! -f "$PROJECT_DIR/$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
        log_error "Xcode project not found"
        exit 1
    fi
    
    # Validate required directories
    validate_directories
    
    # Check permissions
    check_permissions
}

check_required_tools() {
    local required_tools=("xcodebuild" "xcrun" "swift" "git")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -eq 0 ]; then
        log_success "All required tools are available"
        return 0
    else
        log_error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
}

validate_directories() {
    local required_dirs=("$BUILD_DIR" "$CACHE_DIR" "$REPORTS_DIR" "$LOG_DIR")
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_error "Required directory missing: $dir"
            exit 1
        fi
    done
}

check_permissions() {
    local required_dirs=("$BUILD_DIR" "$CACHE_DIR" "$REPORTS_DIR" "$LOG_DIR")
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -w "$dir" ]; then
            log_error "No write permission for directory: $dir"
            exit 1
        fi
    done
}

# Export functions
export -f init_environment
export -f validate_environment