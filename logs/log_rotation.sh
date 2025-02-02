# logs/log_rotation.sh
#!/bin/bash

# Log rotation script
MAX_LOG_FILES=10
LOG_DIR="./logs"

rotate_logs() {
    # Remove old logs
    find "$LOG_DIR" -name "*.log" -type f -mtime +7 -delete
    
    # Compress logs older than 1 day
    find "$LOG_DIR" -name "*.log" -type f -mtime +1 -exec gzip {} \;
}