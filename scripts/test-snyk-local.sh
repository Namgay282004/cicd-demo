#!/bin/bash

# Snyk Local Testing Script
# This script helps you test Snyk integration locally before pushing to GitHub

set -e

echo "🔍 Snyk Local Testing Script"
echo "================================"

# Check if Snyk is installed
if ! command -v snyk &> /dev/null; then
    echo "❌ Snyk CLI not found. Installing..."
    npm install -g snyk
    echo "✅ Snyk CLI installed"
fi

# Check Snyk version
echo "📦 Snyk version: $(snyk --version)"

# Check if authenticated
if ! snyk auth --check &> /dev/null; then
    echo "🔐 Not authenticated with Snyk. Please run: snyk auth"
    echo "Or set SNYK_TOKEN environment variable"
    exit 1
fi

echo "✅ Snyk authentication verified"

# Build the project first
echo "🔨 Building project..."
if command -v mvn &> /dev/null; then
    mvn clean compile -DskipTests
    echo "✅ Maven build completed"
elif [ -f "./mvnw" ]; then
    ./mvnw clean compile -DskipTests
    echo "✅ Maven wrapper build completed"
else
    echo "❌ No Maven found. Please install Maven or use Maven wrapper"
    exit 1
fi

# Function to run dependency scan
run_dependency_scan() {
    local severity=${1:-"high"}
    echo "🔍 Running dependency scan (severity: $severity)..."
    
    if snyk test --maven --severity-threshold="$severity" --json-file-output=snyk-deps-local.json; then
        echo "✅ No vulnerabilities found above $severity severity"
    else
        echo "⚠️ Vulnerabilities found. Check snyk-deps-local.json for details"
        
        # Show summary if jq is available
        if command -v jq &> /dev/null; then
            echo "📊 Vulnerability Summary:"
            cat snyk-deps-local.json | jq -r '.vulnerabilities[] | "- \(.title) (\(.severity)): \(.packageName)@\(.version)"' 2>/dev/null || echo "Could not parse vulnerability details"
        fi
        
        return 1
    fi
}

# Function to run code scan
run_code_scan() {
    local severity=${1:-"high"}
    echo "🔍 Running code security scan (severity: $severity)..."
    
    if snyk code test --severity-threshold="$severity" --json-file-output=snyk-code-local.json; then
        echo "✅ No code security issues found above $severity severity"
    else
        echo "⚠️ Code security issues found. Check snyk-code-local.json for details"
        
        # Show summary if jq is available
        if command -v jq &> /dev/null; then
            echo "📊 Code Issues Summary:"
            cat snyk-code-local.json | jq -r '.runs[0].results[]? | "- \(.ruleId): \(.message.text) (\(.level))"' 2>/dev/null || echo "Could not parse code issues"
        fi
        
        return 1
    fi
}

# Function to test container (if Dockerfile exists)
run_container_scan() {
    if [ ! -f "Dockerfile" ] && [ ! -f "dockerfile" ]; then
        echo "ℹ️ No Dockerfile found, skipping container scan"
        return 0
    fi
    
    local severity=${1:-"critical"}
    echo "🐳 Running container scan (severity: $severity)..."
    
    # Build the image first
    docker build -t cicd-demo-local:test . || {
        echo "❌ Failed to build Docker image"
        return 1
    }
    
    if snyk container test cicd-demo-local:test --severity-threshold="$severity" --json-file-output=snyk-container-local.json; then
        echo "✅ No container vulnerabilities found above $severity severity"
    else
        echo "⚠️ Container vulnerabilities found. Check snyk-container-local.json for details"
        return 1
    fi
}

# Parse command line arguments
SCAN_TYPE="all"
SEVERITY="high"
DEBUG_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            SCAN_TYPE="$2"
            shift 2
            ;;
        -s|--severity)
            SEVERITY="$2"
            shift 2
            ;;
        -d|--debug)
            DEBUG_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -t, --type TYPE      Scan type: deps, code, container, all (default: all)"
            echo "  -s, --severity LEVEL Severity threshold: low, medium, high, critical (default: high)"
            echo "  -d, --debug          Enable debug mode"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Set debug environment if requested
if [ "$DEBUG_MODE" = true ]; then
    export DEBUG="snyk"
    echo "🐛 Debug mode enabled"
fi

echo "🎯 Running scans with severity threshold: $SEVERITY"

# Run scans based on type
SCAN_FAILED=false

case $SCAN_TYPE in
    "deps"|"dependencies")
        run_dependency_scan "$SEVERITY" || SCAN_FAILED=true
        ;;
    "code")
        run_code_scan "$SEVERITY" || SCAN_FAILED=true
        ;;
    "container")
        run_container_scan "$SEVERITY" || SCAN_FAILED=true
        ;;
    "all")
        echo "🚀 Running all scan types..."
        run_dependency_scan "$SEVERITY" || SCAN_FAILED=true
        run_code_scan "$SEVERITY" || SCAN_FAILED=true
        run_container_scan "$SEVERITY" || SCAN_FAILED=true
        ;;
    *)
        echo "❌ Invalid scan type: $SCAN_TYPE"
        echo "Valid types: deps, code, container, all"
        exit 1
        ;;
esac

# Final summary
echo ""
echo "📋 Scan Summary"
echo "==============="
echo "Scan type: $SCAN_TYPE"
echo "Severity threshold: $SEVERITY"
echo "Debug mode: $DEBUG_MODE"

if [ "$SCAN_FAILED" = true ]; then
    echo "❌ Some scans found issues. Review the JSON output files for details."
    echo ""
    echo "Generated files:"
    ls -la snyk-*-local.json 2>/dev/null || echo "No output files generated"
    echo ""
    echo "💡 To fix issues:"
    echo "   1. Review vulnerability details in the JSON files"
    echo "   2. Update dependencies to secure versions"
    echo "   3. Consider adding ignores to .snyk file for accepted risks"
    echo "   4. Re-run this script to verify fixes"
    exit 1
else
    echo "✅ All scans passed! Your code is ready for CI/CD pipeline."
    
    # Clean up output files on success
    rm -f snyk-*-local.json
fi

echo ""
echo "🎉 Local Snyk testing completed successfully!"
