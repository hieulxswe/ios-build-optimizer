#!/bin/bash

# Import required utilities
source "$PROJECT_ROOT/utils/logger.sh"
source "$PROJECT_ROOT/utils/calculations.sh"

# Analyze overall build performance
analyze_build_performance() {
    local start_time=$1
    local end_time=$2
    local total_files=$3
    local output_dir="$REPORTS_DIR/performance"
    
    mkdir -p "$output_dir"
    
    local build_duration=$((end_time - start_time))
    local files_per_second=0
    
    if (( build_duration > 0 )); then
        files_per_second=$(bc <<< "scale=2; $total_files / $build_duration")
    fi
    
    # Generate performance metrics
    {
        echo "# Build Performance Analysis"
        echo "## Build Metrics"
        echo "- Total build time: ${build_duration}s"
        echo "- Files processed: $total_files"
        echo "- Processing speed: ${files_per_second} files/second"
        echo
        echo "## Resource Usage"
        echo "- Peak Memory Usage: $(get_peak_memory)MB"
        echo "- Average CPU Usage: $(get_cpu_usage)%"
        echo "- Disk I/O: $(get_disk_io)MB/s"
        echo
        echo "## Cache Performance"
        local cache_metrics=($(calculate_cache_metrics))
        echo "- Cache Hit Rate: ${cache_metrics[0]}%"
        echo "- Cache Miss Rate: ${cache_metrics[1]}%"
        echo
        echo "## Critical Paths"
        find_performance_bottlenecks
        echo
        echo "## Recommendations"
        generate_performance_recommendations
    } > "$output_dir/performance_report.md"
    
    log_success "Performance report generated: $output_dir/performance_report.md"
}

# Find performance bottlenecks
find_performance_bottlenecks() {
    echo "### Slow Building Files (>5s):"
    find_slow_compilations
    
    echo "### Heavy Dependency Files:"
    find_heavy_dependencies
    
    echo "### Resource Intensive Operations:"
    find_resource_intensive_ops
}

# Find slow compiling files
find_slow_compilations() {
    grep "compilation time" "$LOG_FILE" | \
    awk '{if ($NF > 5) print "- " $1 ": " $NF "s"}' || \
    echo "No slow compilations found"
}

# Find files with many dependencies
find_heavy_dependencies() {
    find "$PROJECT_DIR" -name "*.swift" -exec sh -c '
        imports=$(grep -c "^import" "$1")
        if [ "$imports" -gt 10 ]; then
            echo "- $(basename "$1"): $imports imports"
        fi
    ' sh {} \; || echo "No heavy dependencies found"
}

# Find resource intensive operations
find_resource_intensive_ops() {
    local high_memory=$(grep "high memory usage" "$LOG_FILE" | tail -n 5)
    local high_cpu=$(grep "high CPU usage" "$LOG_FILE" | tail -n 5)
    
    if [ -n "$high_memory" ] || [ -n "$high_cpu" ]; then
        [ -n "$high_memory" ] && echo "High Memory Usage Operations:" && echo "$high_memory"
        [ -n "$high_cpu" ] && echo "High CPU Usage Operations:" && echo "$high_cpu"
    else
        echo "No resource intensive operations found"
    fi
}

# Get peak memory usage in MB
get_peak_memory() {
    local memory_kb=$(ps -o rss= -p $$ 2>/dev/null || echo "0")
    bc <<< "scale=2; $memory_kb / 1024"
}

# Get average CPU usage percentage
get_cpu_usage() {
    local cpu_percent=$(ps -o %cpu= -p $$ 2>/dev/null || echo "0")
    printf "%.1f" "$cpu_percent"
}

# Get disk I/O in MB/s
get_disk_io() {
    if command -v iostat &> /dev/null; then
        local io_stats=$(iostat -d | grep "^${PROJECT_DIR}" | awk '{print $3}')
        bc <<< "scale=2; ${io_stats:-0} / 1024"
    else
        echo "0"
    fi
}

# Generate performance recommendations
generate_performance_recommendations() {
    local build_duration=$((BUILD_END_TIME - BUILD_START_TIME))
    
    echo "### Performance Recommendations:"
    
    # Build time recommendations
    if (( build_duration > 300 )); then
        echo "- Consider enabling parallel builds"
        echo "- Review and optimize slow building files"
    fi
    
    # Memory usage recommendations
    local memory_usage=$(get_peak_memory)
    if (( $(echo "$memory_usage > 1024" | bc -l) )); then
        echo "- Review memory intensive operations"
        echo "- Consider implementing memory optimization strategies"
    fi
    
    # Cache recommendations
    local cache_metrics=($(calculate_cache_metrics))
    if (( $(echo "${cache_metrics[1]} > 30" | bc -l) )); then
        echo "- Optimize cache usage to improve build times"
        echo "- Review cache invalidation strategy"
    fi
    
    # Dependency recommendations
    if [ -n "$(find_heavy_dependencies)" ]; then
        echo "- Consider modularizing heavy dependency files"
        echo "- Review import statements for optimization"
    fi
}