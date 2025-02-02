#!/bin/bash

analyze_code_coverage() {
    local files=("$@")
    local total_lines=0
    local covered_lines=0
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            local file_lines=$(wc -l < "$file")
            total_lines=$((total_lines + file_lines))
            
            local executed_lines=$(grep -v "^$\|^\s*\/\/\|^\s*\/" "$file" | wc -l)
            covered_lines=$((covered_lines + executed_lines))
        fi
    done
    
    local coverage_percent=0
    if (( total_lines > 0 )); then
        coverage_percent=$(bc <<< "scale=2; ($covered_lines / $total_lines) * 100")
    fi
    
    echo "Code Coverage: ${coverage_percent}%"
}
