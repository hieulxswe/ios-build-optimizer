#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/utils/logger.sh"

CACHE_FILE="$PROJECT_ROOT/cache/build_cache.dat"

init_cache_manager() {
    log_info "Initializing cache manager..."
    mkdir -p "$(dirname "$CACHE_FILE")"
    load_existing_cache
}

load_existing_cache() {
    if [[ -f "$CACHE_FILE" ]]; then
        while IFS= read -r line; do
            key=$(echo "$line" | cut -d'=' -f1)
            value=$(echo "$line" | cut -d'=' -f2)
            cache_put "$key" "$value"
        done < "$CACHE_FILE"
    fi
}

cache_put() {
    local key=$1
    local value=$2
    echo "$key=$value" >> "$CACHE_FILE"
    
    local cache_size=$(wc -l < "$CACHE_FILE")
    if [[ $cache_size -gt $MAX_CACHE_SIZE ]]; then
        tail -n $MAX_CACHE_SIZE "$CACHE_FILE" > "$CACHE_FILE.tmp"
        mv "$CACHE_FILE.tmp" "$CACHE_FILE"
    fi
}

cache_get() {
    local key=$1
    local value=$(grep "^$key=" "$CACHE_FILE" | tail -n1 | cut -d'=' -f2)
    if [[ -n "$value" ]]; then
        echo "$value"
        return 0
    fi
    return 1
}

clear_cache() {
    log_info "Clearing cache..."
    rm -f "$CACHE_FILE"
    mkdir -p "$(dirname "$CACHE_FILE")"
    touch "$CACHE_FILE"
}
