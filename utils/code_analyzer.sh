#!/bin/bash

analyze_code_quality() {
    local project_dir=$1
    local report_dir="$PROJECT_ROOT/reports/code_quality"
    
    mkdir -p "$report_dir"
    
    # Analyze code complexity
    analyze_complexity "$project_dir" > "$report_dir/complexity.json"
    
    # Check coding standards
    check_swift_lint "$project_dir" > "$report_dir/lint.json"
    
    # Analyze test coverage
    analyze_test_coverage "$project_dir" > "$report_dir/coverage.json"
    
    # Generate final report
    generate_code_quality_report "$report_dir"
}

analyze_complexity() {
    local dir=$1
    
    find "$dir" -name "*.swift" -exec sh -c '
        echo "Analyzing $(basename {})"
        
        # Count number of methods
        methods=$(grep -c "func" "{}")
        
        # Calculate cyclomatic complexity
        complexity=$(grep -c "if\|for\|while\|case" "{}")
        
        # Check file length
        lines=$(wc -l < "{}")
        
        echo "{
            \"file\": \"$(basename {})\",
            \"methods\": $methods,
            \"complexity\": $complexity,
            \"lines\": $lines
        }"
    ' \;
}

check_swift_lint() {
    local dir=$1
    
    if command -v swiftlint &> /dev/null; then
        cd "$dir" && swiftlint lint --reporter json
    else
        echo "{\"warning\": \"SwiftLint not installed\"}"
    fi
}

analyze_test_coverage() {
    local dir=$1
    
    # Run tests with coverage
    xcodebuild test \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -destination 'platform=iOS Simulator,name=iPhone 14' \
        -enableCodeCoverage YES \
        -resultBundlePath "$dir/coverage.xcresult"
    
    # Parse coverage data
    xcrun xccov view --report "$dir/coverage.xcresult" --json
}

generate_code_quality_report() {
    local report_dir=$1
    local output="$report_dir/final_report.md"
    
    cat << EOF > "$output"
# Code Quality Report

## Complexity Analysis
$(jq -r '.[] | "- \(.file): \(.complexity) complexity, \(.methods) methods, \(.lines) lines"' "$report_dir/complexity.json")

## Lint Results
$(jq -r '.[] | "- \(.file): \(.reason)"' "$report_dir/lint.json")

## Test Coverage
$(jq -r '.data.targets[] | "- \(.name): \(.lineCoverage)% coverage"' "$report_dir/coverage.json")

## Recommendations
$(generate_code_recommendations)
EOF
}

generate_code_recommendations() {
    cat << EOF
1. Files requiring attention (high complexity):
   $(jq -r 'sort_by(.complexity) | .[-5:] | .[] | "  - \(.file) (complexity: \(.complexity))"' "$report_dir/complexity.json")

2. Test coverage improvements needed:
   $(jq -r '.data.targets | sort_by(.lineCoverage) | .[0:5] | .[] | "  - \(.name) (\(.lineCoverage)% coverage)"' "$report_dir/coverage.json")

3. Code style violations:
   $(jq -r 'group_by(.rule_id) | .[] | "  - \(.[0].rule_id): \(length) occurrences"' "$report_dir/lint.json")
EOF
}