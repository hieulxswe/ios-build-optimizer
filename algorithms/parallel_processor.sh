#!/bin/bash

process_in_parallel() {
    local -a tasks=("$@")
    local max_jobs=$(sysctl -n hw.ncpu 2>/dev/null || echo "2")
    local running=0
    local job_pids=()
    
    for task in "${tasks[@]}"; do
        # Wait if we've reached max jobs
        while [ $running -ge $max_jobs ]; do
            for pid in "${job_pids[@]}"; do
                if ! kill -0 $pid 2>/dev/null; then
                    running=$((running - 1))
                fi
            done
            sleep 1
        done
        
        # Start new job
        process_task "$task" &
        job_pids+=($!)
        running=$((running + 1))
    done
    
    # Wait for all remaining jobs
    wait
}

process_task() {
    local task=$1
    if [[ -f "$task" ]]; then
        log_info "Processing: $task"
        return 0
    else
        log_error "File not found: $task"
        return 1
    fi
}