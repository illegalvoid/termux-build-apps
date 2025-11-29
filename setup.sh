#!/data/data/com.termux/files/usr/bin/bash

# Termux Android Build Environment Setup Script
# This script automates the complete setup process for building Android apps in Termux

set -e  # Exit on error

echo "================================================"
echo "Termux Android Build Environment Setup"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Step 1: Update and upgrade packages
print_info "Updating and upgrading Termux packages..."
pkg update -y && pkg upgrade -y
print_status "Packages updated successfully"
echo ""

# Step 2: Install required packages (Java 21 - latest LTS)
print_info "Installing OpenJDK 21 and wget..."
pkg install wget openjdk-21 -y
print_status "Required packages installed"
echo ""

# Verify Java installation
print_info "Verifying Java installation..."
if java -version 2>&1 | grep -q "openjdk"; then
    print_status "Java installed successfully:"
    java -version 2>&1 | head -n 1
else
    print_error "Java installation failed"
    exit 1
fi
echo ""

# Step 3: Install Android SDK
print_info "Installing Android SDK..."
if [ ! -d "$HOME/android-sdk" ]; then
    wget -O ~/install-android-sdk.sh https://raw.githubusercontent.com/Sohil876/termux-sdk-installer/main/installer.sh
    chmod +x ~/install-android-sdk.sh
    bash ~/install-android-sdk.sh -i
    print_status "Android SDK installed"
else
    print_info "Android SDK already exists, skipping installation"
fi
echo ""

# Source bashrc to get ANDROID_HOME
source ~/.bashrc 2>/dev/null || export ANDROID_HOME=$HOME/android-sdk

# Step 4: Accept Android SDK licenses
print_info "Accepting Android SDK licenses..."
yes | sdkmanager --licenses > /dev/null 2>&1
print_status "Licenses accepted"
echo ""

# Step 5: Install latest Android platform (API 35 - Android 15)
print_info "Installing Android platform API 35..."
yes | sdkmanager "platforms;android-35"
print_status "Android platform installed"
echo ""

# Step 6: Install Gradle 8.10.2 (latest stable)
GRADLE_VERSION="8.10.2"
print_info "Installing Gradle ${GRADLE_VERSION}..."

if [ ! -d "$ANDROID_HOME/gradle" ]; then
    wget -O $ANDROID_HOME/gradle-${GRADLE_VERSION}-bin.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
    unzip -q $ANDROID_HOME/gradle-${GRADLE_VERSION}-bin.zip -d $ANDROID_HOME/
    mv $ANDROID_HOME/gradle-${GRADLE_VERSION}/ $ANDROID_HOME/gradle/
    rm $ANDROID_HOME/gradle-${GRADLE_VERSION}-bin.zip
    print_status "Gradle installed"
else
    print_info "Gradle already exists, skipping installation"
fi
echo ""

# Step 7: Add Gradle to PATH if not already added
if ! grep -q "ANDROID_HOME/gradle/bin" ~/.bashrc; then
    echo 'export PATH=${PATH}:${ANDROID_HOME}/gradle/bin' >> ~/.bashrc
    print_status "Gradle added to PATH"
fi
source ~/.bashrc

# Verify Gradle installation
print_info "Verifying Gradle installation..."
export PATH=${PATH}:${ANDROID_HOME}/gradle/bin
if gradle -v 2>&1 | grep -q "Gradle"; then
    print_status "Gradle installed successfully:"
    gradle -v | head -n 3
else
    print_error "Gradle installation failed"
    exit 1
fi
echo ""

# Step 8: Fix aapt2 issue
print_info "Configuring aapt2 path..."
mkdir -p ~/.gradle
GRADLE_PROPERTIES="$HOME/.gradle/gradle.properties"

# Find the latest build-tools version
BUILD_TOOLS_VERSION=$(ls -1 $ANDROID_HOME/build-tools/ | sort -V | tail -n 1)

if [ -n "$BUILD_TOOLS_VERSION" ]; then
    AAPT2_PATH="$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION/aapt2"
    
    # Check if aapt2 line already exists
    if grep -q "android.aapt2FromMavenOverride" "$GRADLE_PROPERTIES" 2>/dev/null; then
        # Update existing line
        sed -i "s|android.aapt2FromMavenOverride=.*|android.aapt2FromMavenOverride=$AAPT2_PATH|" "$GRADLE_PROPERTIES"
    else
        # Add new line
        echo "android.aapt2FromMavenOverride=$AAPT2_PATH" >> "$GRADLE_PROPERTIES"
    fi
    print_status "aapt2 path configured (build-tools version: $BUILD_TOOLS_VERSION)"
else
    print_error "Could not find build-tools directory"
    exit 1
fi
echo ""

# Final summary
echo "================================================"
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "================================================"
echo ""
echo "Installed versions:"
echo "  - Java: $(java -version 2>&1 | head -n 1)"
echo "  - Gradle: $(gradle -v 2>&1 | grep "Gradle" | head -n 1)"
echo "  - Android Platform: API 35"
echo "  - Build Tools: $BUILD_TOOLS_VERSION"
echo ""
echo "Environment variables:"
echo "  - ANDROID_HOME: $ANDROID_HOME"
echo "  - Gradle in PATH: ${ANDROID_HOME}/gradle/bin"
echo ""
echo -e "${GREEN}You can now build Android apps in Termux!${NC}"
echo "Restart your terminal or run: source ~/.bashrc"
echo ""
