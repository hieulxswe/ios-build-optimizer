#!/bin/bash

# Build Task Manager
execute_build_task() {
    local file=$1
    local start_time=$(date +%s)
    
    log_info "Building: $file"
    
    # Check if file needs rebuilding
    if needs_rebuild "$file"; then
        if perform_build "$file"; then
            ((success_count++))
            cache_build_result "$file" "success"
            log_success "Build successful: $file"
            return 0
        else
            ((error_count++))
            cache_build_result "$file" "error"
            log_error "Build failed: $file"
            return 1
        fi
    else
        log_info "Skip building (up to date): $file"
        return 0
    fi
}

needs_rebuild() {
    local file=$1
    local last_build_time
    
    last_build_time=$(cache_get "build_time_${file}")
    if [[ -z "$last_build_time" ]]; then
        return 0
    fi
    
    local file_time=$(stat -f "%m" "$file")
    if (( file_time > last_build_time )); then
        return 0
    fi
    
    return 1
}

perform_build() {
    local file=$1
    
    case "${file##*.}" in
        "swift")
            build_swift_file "$file"
            ;;
        "m"|"mm")
            build_objc_file "$file"
            ;;
        *)
            log_error "Unsupported file type: $file"
            return 1
            ;;
    esac
}

build_swift_file() {
    local file=$1
    swiftc -sdk "$(xcrun --show-sdk-path --sdk iphonesimulator)" \
           -target "arm64-apple-ios$DEPLOYMENT_TARGET-simulator" \
           -emit-module \
           "$file"
    return $?
}

build_objc_file() {
    local file=$1
    clang -fobjc-arc \
          -sdk "$(xcrun --show-sdk-path --sdk iphonesimulator)" \
          -target "arm64-apple-ios$DEPLOYMENT_TARGET-simulator" \
          -c "$file"
    return $?
}