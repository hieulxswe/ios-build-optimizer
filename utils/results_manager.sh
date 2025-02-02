#!/bin/bash

# Import required modules
source "$PROJECT_ROOT/utils/logger.sh"
source "$PROJECT_ROOT/utils/calculations.sh"

# Initialize results directory
init_results_directory() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    RESULTS_DIR="$PROJECT_ROOT/results/$timestamp"
    mkdir -p "$RESULTS_DIR"
    chmod -R 755 "$RESULTS_DIR"

    cat << EOF > "$RESULTS_DIR/metadata.json"
{
    "build_id": "$timestamp",
    "project_name": "$PROJECT_NAME",
    "build_date": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF

    export RESULTS_DIR
    return 0
}

# Save build results
save_build_results() {
    local report_file="$RESULTS_DIR/report.md"
    local build_duration=$((BUILD_END_TIME - BUILD_START_TIME))
    local success_rate=$(calculate_success_rate "$SUCCESS_COUNT" "$TOTAL_FILES")
    
    cat << EOF > "$report_file"
# Build Report
Generated: $(date '+%Y-%m-%d %H:%M:%S')

## Project Information
- Project: $PROJECT_NAME
- Configuration: $BUILD_CONFIGURATION
- Directory: $PROJECT_DIR

## Build Summary
- Duration: ${build_duration}s
- Total Files: $TOTAL_FILES
- Successful: $SUCCESS_COUNT
- Failed: $ERROR_COUNT
- Success Rate: ${success_rate}%

## Performance Analysis
- Files/Second: $(calculate_files_per_second "$TOTAL_FILES" "$build_duration")
- Average Time/File: $(calculate_average_build_time "$build_duration" "$TOTAL_FILES")s

## Failed Tasks
$(list_failed_tasks)

## Recommendations
$(generate_recommendations)

---
Report Location: $report_file
EOF

    log_info "Build report saved to: $report_file"
}

# List failed tasks
list_failed_tasks() {
    local failed_tasks=$(grep "ERROR" "$LOG_FILE" | tail -n 5)
    if [ -n "$failed_tasks" ]; then
        echo "$failed_tasks"
    else
        echo "No failed tasks found"
    fi
}

# Generate recommendations
generate_recommendations() {
    local recommendations=()
    local build_duration=$((BUILD_END_TIME - BUILD_START_TIME))
    local success_rate=$(calculate_success_rate "$SUCCESS_COUNT" "$TOTAL_FILES")
    
    if [ "$build_duration" -gt 300 ]; then
        recommendations+=("- Consider enabling parallel builds")
    fi
    
    if [ "$success_rate" -lt 100 ]; then
        recommendations+=("- Review failed builds and fix errors")
    fi
    
    if [ "$build_duration" -gt 600 ]; then
        recommendations+=("- Review build process for optimization opportunities")
    fi
    
    printf '%s\n' "${recommendations[@]:-"- No specific recommendations at this time"}"
}

# Clean up old results (keep last 7 days)
cleanup_old_results() {
    find "$PROJECT_ROOT/results" -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
}

# Export functions
export -f init_results_directory
export -f save_build_results
export -f cleanup_old_results