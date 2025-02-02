#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting iOS Build Optimizer installation...${NC}"

# Function to validate project path
validate_project_path() {
    local project_path=$1
    
    # Check if directory exists
    if [ ! -d "$project_path" ]; then
        echo -e "${RED}❌ Directory does not exist: $project_path${NC}"
        return 1
    fi
    
    # Check for .xcodeproj file
    if ! find "$project_path" -maxdepth 1 -name "*.xcodeproj" -type d | grep -q .; then
        echo -e "${RED}❌ No Xcode project found in directory: $project_path${NC}"
        return 1
    fi
    
    # Get project name from .xcodeproj
    PROJECT_NAME=$(basename "$(find "$project_path" -maxdepth 1 -name "*.xcodeproj" -type d | head -n 1)" .xcodeproj)
    
    return 0
}

# Get project path from user
while true; do
    echo -e "${YELLOW}📂 Please enter the path to your Xcode project:${NC}"
    read -r PROJECT_PATH
    
    # Expand ~ to full path if used
    PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"
    
    if validate_project_path "$PROJECT_PATH"; then
        echo -e "${GREEN}✅ Valid Xcode project found: $PROJECT_NAME${NC}"
        break
    else
        echo -e "${YELLOW}Would you like to try again? (y/n)${NC}"
        read -r RETRY
        if [[ ! $RETRY =~ ^[Yy] ]]; then
            echo -e "${RED}Installation cancelled.${NC}"
            exit 1
        fi
    fi
done

echo -e "${BLUE}📁 Creating directory structure...${NC}"
mkdir -p {src,algorithms,utils,configs,logs,cache,build,reports}

echo -e "${BLUE}📝 Creating configuration files...${NC}"

# Create project_config.sh with user's input
cat > configs/project_config.sh << EOF
#!/bin/bash

# Project Information
export PROJECT_DIR="$PROJECT_PATH"
export PROJECT_NAME="$PROJECT_NAME"
export BUILD_CONFIGURATION="Release"
export SCHEME_NAME="\$PROJECT_NAME"

# Build Settings
export SWIFT_VERSION="5.0"
export DEPLOYMENT_TARGET="14.0"
export ENABLE_PARALLEL_BUILD=true
export MAX_CONCURRENT_TASKS=4

# Directory Paths
export BUILD_DIR="\${PROJECT_ROOT}/build"
export CACHE_DIR="\${PROJECT_ROOT}/cache"
export REPORTS_DIR="\${PROJECT_ROOT}/reports"
export LOG_DIR="\${PROJECT_ROOT}/logs"

# Build phases
export CLEAN_BUILD=false
export ENABLE_TESTS=false
export ENABLE_DOCUMENTATION=false

# Analysis Settings
export MIN_TEST_COVERAGE=80
export MAX_FILE_SIZE=400
export MAX_COMPLEXITY=10
export MAX_IMPORTS=10

# Simple validation to ensure project exists
validate_config() {
    if [ ! -d "\$PROJECT_DIR" ]; then
        echo "Error: Project directory not found: \$PROJECT_DIR"
        return 1
    fi
    return 0
}

# Initialize directories
init_directories() {
    mkdir -p "\$BUILD_DIR" "\$CACHE_DIR" "\$REPORTS_DIR" "\$LOG_DIR"
    chmod -R 755 "\$PROJECT_ROOT"
}
EOF

chmod +x configs/project_config.sh

echo -e "${BLUE}📝 Creating utility files...${NC}"

# Create logger.sh
cat > utils/logger.sh << 'EOF'
#!/bin/bash

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure log directory exists
init_logger() {
    LOG_DIR="$PROJECT_ROOT/logs"
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/build_$(date +%Y%m%d_%H%M%S).log"
    touch "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}" | tee -a "${LOG_FILE:-/dev/null}"
}

log_error() {
    echo -e "${RED}[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}" | tee -a "${LOG_FILE:-/dev/null}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}" | tee -a "${LOG_FILE:-/dev/null}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}" | tee -a "${LOG_FILE:-/dev/null}"
}

# Initialize logger when the script is sourced
init_logger
EOF

chmod +x utils/logger.sh

echo -e "${BLUE}📝 Creating algorithm files...${NC}"

# Copy other necessary files...

# Set permissions
find . -type f -name "*.sh" -exec chmod +x {} \;

echo -e "${GREEN}✅ Installation completed!${NC}"
echo -e "${GREEN}📝 Configuration is ready${NC}"
echo -e "${GREEN}🚀 To start the build optimizer, run: ./src/main.sh${NC}"

# Show configuration summary
echo -e "\n${BLUE}Configuration Summary:${NC}"
echo -e "Project Path: ${YELLOW}$PROJECT_PATH${NC}"
echo -e "Project Name: ${YELLOW}$PROJECT_NAME${NC}"
echo -e "Build Configuration: ${YELLOW}Release${NC}"

# Ask if user wants to start analysis now
echo -e "\n${YELLOW}Would you like to start project analysis now? (y/n)${NC}"
read -r START_ANALYSIS
if [[ $START_ANALYSIS =~ ^[Yy] ]]; then
    ./src/main.sh
fi