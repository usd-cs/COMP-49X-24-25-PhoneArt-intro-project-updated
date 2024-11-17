#!/bin/bash
SCHEME='COMP-49X-24-25-PhoneArt-intro-project-updated'
DESTINATION='platform=iOS Simulator,OS=18.1,name=iPhone 16'
xcodebuild -project COMP-49X-24-25-PhoneArt-intro-project-updated.xcodeproj -scheme $SCHEME -destination "$DESTINATION" build test CODE_SIGNING_ALLOWED='NO'
killall "iOS Simulator" 2>/dev/null || true
