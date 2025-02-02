#!/bin/bash

CONFIG_FILE="$PROJECT_ROOT/configs/project_config.sh"

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        log_info "Configuration loaded from $CONFIG_FILE"
    else
        create_default_config
        source "$CONFIG_FILE"
        log_info "Default configuration created and loaded"
    fi
}

create_default_config() {
    log_info "Creating default configuration..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    cat > "$CONFIG_FILE" << 'CONFIG_EOF'
#!/bin/bash

# Project Configuration
PROJECT_DIR="/Users/hieuxuanleu/Desktop/NSWLiveTraffic"
PROJECT_NAME="NSWLiveTraffic"
BUILD_CONFIGURATION="Release"
SCHEME_NAME="$PROJECT_NAME"

# Build paths
BUILD_DIR="./build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/Export"

# Cache settings
CACHE_DIR="./cache"
MAX_CACHE_SIZE=1000

# Compiler settings
SWIFT_VERSION="5.0"
DEPLOYMENT_TARGET="14.0"

# Build options
ENABLE_PARALLEL_BUILD=true
MAX_CONCURRENT_TASKS=4
CONFIG_EOF

    chmod +x "$CONFIG_FILE"
}
