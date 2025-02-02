#!/bin/bash

analyze_memory_usage() {
    local process_id=$1
    
    while ps -p $process_id > /dev/null 2>&1; do
        local memory=$(ps -o rss= -p $process_id 2>/dev/null || echo "0")
        echo "Current memory usage: ${memory}KB"
        sleep 1
    done
}
