#!/bin/bash

# ========================================
# JP Universe - Build APK Script
# ========================================

echo "🤖 JP Universe - Build APK"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_DIR="/home/ubuntu/jp-universe-mobile"
BUILD_OUTPUT="$PROJECT_DIR/builds"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Print functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project not found at: $PROJECT_DIR"
    exit 1
fi

print_success "Project found"

# Create build output directory
mkdir -p "$BUILD_OUTPUT"
print_success "Build directory created"

# Change to project directory
cd "$PROJECT_DIR" || exit 1
print_success "Entering project directory"

# Install dependencies
echo ""
echo -e "${BLUE}📦 Installing dependencies...${NC}"
pnpm install --no-frozen-lockfile > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_success "Dependencies installed"
else
    print_error "Error installing dependencies"
    exit 1
fi

# Clean cache
echo ""
echo -e "${BLUE}🧹 Cleaning cache...${NC}"
rm -rf node_modules/.cache > /dev/null 2>&1
print_success "Cache cleaned"

# Build for Android
echo ""
echo -e "${BLUE}🔨 Compiling for Android...${NC}"

print_info "Attempting to use EAS Build (cloud)..."
eas build --platform android --release --non-interactive 2>&1 | tee "$BUILD_OUTPUT/build_$TIMESTAMP.log"

if [ $? -eq 0 ]; then
    print_success "Build completed successfully!"
    echo ""
    echo -e "${GREEN}=================================="
    echo "✓ APK generated successfully!"
    echo "=================================="
    echo ""
    print_info "The APK will be sent to your email or available in EAS Build"
    print_info "Visit: https://expo.dev/builds"
else
    print_warning "EAS Build not available, trying local build..."
    
    # Option 2: Local build with Gradle
    if [ -d "$PROJECT_DIR/android" ]; then
        cd "$PROJECT_DIR/android" || exit 1
        ./gradlew assembleRelease 2>&1 | tee "$BUILD_OUTPUT/gradle_build_$TIMESTAMP.log"
        
        if [ $? -eq 0 ]; then
            APK_PATH="$PROJECT_DIR/android/app/build/outputs/apk/release/app-release.apk"
            if [ -f "$APK_PATH" ]; then
                cp "$APK_PATH" "$BUILD_OUTPUT/jp-universe-$TIMESTAMP.apk"
                print_success "APK copied to: $BUILD_OUTPUT/jp-universe-$TIMESTAMP.apk"
            fi
        else
            print_error "Error compiling with Gradle"
            exit 1
        fi
    else
        print_error "Android directory not found"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}=================================="
echo "📱 Build Finished!"
echo "=================================="
echo ""
print_info "Build files: $BUILD_OUTPUT"
print_info "Build log: $BUILD_OUTPUT/build_$TIMESTAMP.log"
echo ""
print_info "Next steps:"
echo "  1. Download the APK"
echo "  2. Transfer to your Android device"
echo "  3. Install the app"
echo "  4. Enjoy! 🎮"
echo ""
