#!/bin/bash

# Import required utilities
source "$PROJECT_ROOT/utils/logger.sh"

# Calculate success rate as percentage
calculate_success_rate() {
    local success=$1
    local total=$2
    
    if [ "$total" -eq 0 ]; then
        echo "0"
    else
        bc <<< "scale=2; ($success * 100) / $total"
    fi
}

# Calculate files processed per second
calculate_files_per_second() {
    local total_files=$1
    local duration=$2
    
    if [ "$duration" -eq 0 ]; then
        echo "0"
    else
        bc <<< "scale=2; $total_files / $duration"
    fi
}

# Calculate average build time per file
calculate_average_build_time() {
    local total_time=$1
    local total_files=$2
    
    if [ "$total_files" -eq 0 ]; then
        echo "0"
    else
        bc <<< "scale=2; $total_time / $total_files"
    fi
}

# Calculate memory usage in MB
calculate_memory_usage() {
    local pid=$1
    local memory_kb=$(ps -o rss= -p "$pid" 2>/dev/null || echo "0")
    bc <<< "scale=2; $memory_kb / 1024"
}

# Calculate CPU usage percentage
calculate_cpu_usage() {
    local pid=$1
    local cpu_percent=$(ps -o %cpu= -p "$pid" 2>/dev/null || echo "0")
    printf "%.1f" "$cpu_percent"
}

# Calculate disk I/O in MB
calculate_disk_io() {
    local dir=$1
    if command -v iostat &> /dev/null; then
        local io_stats=$(iostat -d | grep "^${dir}" | awk '{print $3}')
        bc <<< "scale=2; $io_stats / 1024"
    else
        echo "0"
    fi
}

# Calculate cache effectiveness
calculate_cache_metrics() {
    local cache_file="$CACHE_DIR/cache_stats.json"
    local hits=0
    local misses=0
    local total=0
    
    if [ -f "$cache_file" ]; then
        hits=$(jq '.hits' "$cache_file")
        misses=$(jq '.misses' "$cache_file")
        total=$((hits + misses))
    fi
    
    if [ "$total" -eq 0 ]; then
        echo "hit_rate=0"
        echo "miss_rate=0"
    else
        local hit_rate=$(bc <<< "scale=2; ($hits * 100) / $total")
        local miss_rate=$(bc <<< "scale=2; ($misses * 100) / $total")
        echo "hit_rate=$hit_rate"
        echo "miss_rate=$miss_rate"
    fi
}

# Calculate code coverage percentage
calculate_code_coverage() {
    local coverage_data="$PROJECT_ROOT/reports/coverage/coverage.json"
    
    if [ -f "$coverage_data" ]; then
        local covered=$(jq '.covered_lines' "$coverage_data")
        local total=$(jq '.total_lines' "$coverage_data")
        
        if [ "$total" -gt 0 ]; then
            bc <<< "scale=2; ($covered * 100) / $total"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Calculate dependency complexity
calculate_dependency_complexity() {
    local project_dir=$1
    local total_imports=0
    local unique_imports=0
    
    # Count total imports
    total_imports=$(find "$project_dir" -name "*.swift" -exec grep -h "^import" {} \; | wc -l)
    
    # Count unique imports
    unique_imports=$(find "$project_dir" -name "*.swift" -exec grep -h "^import" {} \; | sort -u | wc -l)
    
    # Calculate complexity score (ratio of total to unique imports)
    if [ "$unique_imports" -eq 0 ]; then
        echo "1.00"
    else
        bc <<< "scale=2; $total_imports / $unique_imports"
    fi
}

# Calculate build speed trend
calculate_build_speed_trend() {
    local current_speed=$1
    local history_file="$PROJECT_ROOT/reports/history/build_speeds.log"
    
    # Add current speed to history
    echo "$(date +%s) $current_speed" >> "$history_file"
    
    # Calculate trend from last 5 builds
    if [ -f "$history_file" ]; then
        local avg_speed=$(tail -n 5 "$history_file" | awk '{sum += $2} END {print sum/NR}')
        bc <<< "scale=2; $current_speed - $avg_speed"
    else
        echo "0"
    fi
}

# Calculate build health score (0-100)
calculate_build_health() {
    local success_rate=$1
    local build_time=$2
    local cache_hit_rate=$3
    
    # Weight factors
    local w_success=0.5
    local w_time=0.3
    local w_cache=0.2
    
    # Normalize build time (assuming 300s is maximum acceptable)
    local time_score=$(bc <<< "scale=2; (1 - ($build_time / 300)) * 100")
    if (( $(echo "$time_score < 0" | bc -l) )); then
        time_score=0
    fi
    
    # Calculate weighted score
    local health_score=$(bc <<< "scale=2; ($success_rate * $w_success) + ($time_score * $w_time) + ($cache_hit_rate * $w_cache)")
    printf "%.1f" "$health_score"
}

# Calculate resource efficiency
calculate_resource_efficiency() {
    local build_time=$1
    local memory_mb=$2
    local cpu_percent=$3
    
    # Calculate efficiency score (lower is better)
    local efficiency=$(bc <<< "scale=2; ($build_time * $memory_mb * $cpu_percent) / 100000")
    printf "%.2f" "$efficiency"
}

# Format time duration in human readable format
format_duration() {
    local seconds=$1
    
    if [ "$seconds" -lt 60 ]; then
        echo "${seconds}s"
    elif [ "$seconds" -lt 3600 ]; then
        local minutes=$((seconds / 60))
        local remaining_seconds=$((seconds % 60))
        echo "${minutes}m ${remaining_seconds}s"
    else
        local hours=$((seconds / 3600))
        local minutes=$(((seconds % 3600) / 60))
        local remaining_seconds=$((seconds % 60))
        echo "${hours}h ${minutes}m ${remaining_seconds}s"
    fi
}

# Format file size in human readable format
format_size() {
    local size=$1
    
    if [ "$size" -lt 1024 ]; then
        echo "${size}B"
    elif [ "$size" -lt 1048576 ]; then
        bc <<< "scale=1; $size / 1024"
        echo "KB"
    else
        bc <<< "scale=1; $size / 1048576"
        echo "MB"
    fi
}

# Export functions for use in other scripts
export -f calculate_success_rate
export -f calculate_files_per_second
export -f calculate_average_build_time
export -f calculate_memory_usage
export -f calculate_cpu_usage
export -f calculate_disk_io
export -f calculate_cache_metrics
export -f calculate_code_coverage
export -f calculate_dependency_complexity
export -f calculate_build_speed_trend
export -f calculate_build_health
export -f calculate_resource_efficiency
export -f format_duration
export -f format_size