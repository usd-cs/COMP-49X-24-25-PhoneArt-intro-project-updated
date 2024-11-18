#!/bin/bash

# Kill any running simulators first
echo "Cleaning up existing simulators..."
xcrun simctl shutdown all 2>/dev/null
killall "Simulator" 2>/dev/null
killall "iOS Simulator" 2>/dev/null

# Clear derived data
echo "Clearing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Set variables
SCHEME='COMP-49X-24-25-PhoneArt-intro-project-updated'
DESTINATION='platform=iOS Simulator,OS=18.1,name=iPhone 16'

# Clean the build first
echo "Cleaning build..."
xcodebuild clean -project "$SCHEME.xcodeproj" -scheme "$SCHEME"

# Build and test with more verbose output
echo "Running tests..."
xcodebuild \
    -project "$SCHEME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -allowProvisioningUpdates \
    clean build test \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    -verbose

# Check exit status
if [ $? -ne 0 ]; then
    echo "Error: Build or tests failed"
    exit 1
fi
