# configs/xcode_config.sh
#!/bin/bash

# Xcode Build Settings
DEVELOPMENT_TEAM=""
PROVISIONING_PROFILE="YOUR_PROVISIONING_PROFILE"
CODE_SIGN_IDENTITY="iPhone Developer"
BUNDLE_ID="com.yourcompany.app"

# Device Settings
SIMULATOR_NAME="iPhone 14"
SIMULATOR_OS="16.0"

# Archive Settings
ARCHIVE_METHOD="ad-hoc"  # or "app-store", "enterprise"