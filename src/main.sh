#!/bin/bash

# Get absolute path to project root
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Import required modules
source "$PROJECT_ROOT/utils/logger.sh"
source "$PROJECT_ROOT/configs/project_config.sh"
source "$PROJECT_ROOT/utils/project_analyzer.sh"

# Create results directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="$PROJECT_ROOT/results/$TIMESTAMP"
mkdir -p "$RESULTS_DIR"

# Initialize directories
init_directories

log_info "Starting iOS Build Optimizer..."

# Start analysis
log_info "Analyzing project at: $PROJECT_DIR"
analyze_project

# Generate report
log_info "Generating detailed report..."
generate_detailed_report

log_success "Analysis completed. Check results at: $RESULTS_DIR/build_report.md"