#!/bin/bash

# Dependency Analyzer
analyze_file_dependencies() {
    local file=$1
    log_info "Analyzing dependencies for: $file"
    
    if [[ -f "$file" ]]; then
        # Analyze import statements
        local imports=$(grep -E "^import\s+.*$" "$file" || true)
        
        for import in $imports; do
            log_info "Found dependency: $import in $file"
        done

        # Analyze custom module imports
        local custom_imports=$(grep -E "^@testable\s+import\s+.*$" "$file" || true)
        for custom_import in $custom_imports; do
            log_info "Found test dependency: $custom_import in $file"
        done
    else
        log_error "File not found: $file"
    fi
}

create_dependency_graph() {
    log_info "Creating dependency graph..."
    local -A graph=()
    
    for file in "${BUILD_QUEUE[@]}"; do
        if [[ -f "$file" ]]; then
            local imports=$(grep -E "^import\s+.*$" "$file" || true)
            graph["$file"]="$imports"
        fi
    done
    
    echo "${graph[@]}"
}