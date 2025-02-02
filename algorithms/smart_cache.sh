#!/bin/bash

# Enhanced Cache Manager
CACHE_FILE="$PROJECT_ROOT/cache/smart_cache.dat"
CACHE_STATS_FILE="$PROJECT_ROOT/cache/cache_stats.json"

init_smart_cache() {
    mkdir -p "$(dirname "$CACHE_FILE")"
    touch "$CACHE_STATS_FILE"
    
    # Initialize cache statistics
    if [[ ! -s "$CACHE_STATS_FILE" ]]; then
        echo '{
            "hits": 0,
            "misses": 0,
            "last_cleanup": 0,
            "size": 0
        }' > "$CACHE_STATS_FILE"
    fi
}

smart_cache_put() {
    local key=$1
    local value=$2
    local timestamp=$(date +%s)
    local hash=$(echo "$value" | shasum -a 256 | cut -d' ' -f1)
    
    # Store with metadata
    echo "{\"key\":\"$key\",\"value\":\"$value\",\"hash\":\"$hash\",\"timestamp\":$timestamp}" >> "$CACHE_FILE"
    
    # Update stats
    update_cache_stats "size" "+1"
    
    # Auto cleanup if needed
    check_cache_health
}

smart_cache_get() {
    local key=$1
    local result=$(grep "\"key\":\"$key\"" "$CACHE_FILE" | tail -n1)
    
    if [[ -n "$result" ]]; then
        update_cache_stats "hits" "+1"
        echo "$result" | jq -r '.value'
        return 0
    else
        update_cache_stats "misses" "+1"
        return 1
    fi
}

update_cache_stats() {
    local stat_key=$1
    local operation=$2
    
    local current_value=$(jq ".$stat_key" "$CACHE_STATS_FILE")
    if [[ "$operation" == "+1" ]]; then
        jq ".$stat_key = $((current_value + 1))" "$CACHE_STATS_FILE" > temp.json && mv temp.json "$CACHE_STATS_FILE"
    fi
}

check_cache_health() {
    local current_time=$(date +%s)
    local last_cleanup=$(jq '.last_cleanup' "$CACHE_STATS_FILE")
    
    # Cleanup every 24 hours
    if (( current_time - last_cleanup >= 86400 )); then
        clean_old_entries
        optimize_cache_storage
        jq ".last_cleanup = $current_time" "$CACHE_STATS_FILE" > temp.json && mv temp.json "$CACHE_STATS_FILE"
    fi
}

clean_old_entries() {
    local current_time=$(date +%s)
    local max_age=604800 # 7 days
    
    # Remove entries older than max_age
    cat "$CACHE_FILE" | jq "select(.timestamp > $((current_time - max_age)))" > "$CACHE_FILE.tmp"
    mv "$CACHE_FILE.tmp" "$CACHE_FILE"
}

optimize_cache_storage() {
    # Deduplicate entries with same hash
    cat "$CACHE_FILE" | jq -s 'group_by(.hash) | map(.[0])' > "$CACHE_FILE.tmp"
    mv "$CACHE_FILE.tmp" "$CACHE_FILE"
}