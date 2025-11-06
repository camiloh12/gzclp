# GZCLP App Development Environment Setup Guide

## System Requirements

**Operating System:** Linux (Ubuntu 20.04 or later recommended)
**Minimum Requirements:**
- Disk Space: 2.8 GB (not including disk space for IDE/tools)
- Git
- curl or wget
- Bash shell

## Phase 0: Installing Flutter SDK

### Step 1: Install Required Dependencies

```bash
# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Install OpenJDK for Android development
sudo apt-get install -y openjdk-11-jdk

# Verify Java installation
java -version
```

### Step 2: Download and Install Flutter

```bash
# Navigate to home directory
cd ~

# Clone Flutter repository (stable channel)
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH permanently
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc

# Reload bash configuration
source ~/.bashrc

# Verify Flutter installation
flutter --version
```

### Step 3: Run Flutter Doctor

```bash
# Check for missing dependencies
flutter doctor

# This will show what's missing and what's configured
# Expected output will show items to fix
```

### Step 4: Install Android SDK (for Android Development)

#### Option A: Install Android Studio (Recommended)

```bash
# Download Android Studio from:
# https://developer.android.com/studio

# Extract the downloaded archive
sudo tar -xzf android-studio-*.tar.gz -C /opt/

# Run Android Studio
/opt/android-studio/bin/studio.sh

# During setup:
# 1. Choose "Standard" installation
# 2. Accept licenses
# 3. Download Android SDK components
```

#### Option B: Command-line Android SDK Tools

```bash
# Download command line tools from:
# https://developer.android.com/studio#command-tools

# Create Android SDK directory
mkdir -p ~/Android/Sdk

# Extract command line tools
cd ~/Android/Sdk
mkdir cmdline-tools
unzip ~/Downloads/commandlinetools-linux-*.zip -d cmdline-tools

# Add to PATH
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc

# Accept licenses
flutter doctor --android-licenses

# Install platform tools
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

### Step 5: Configure Flutter for Android

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Configure Flutter
flutter config --android-sdk ~/Android/Sdk

# Run flutter doctor to verify
flutter doctor
```

### Step 6: Install Chrome (for Web Development - Optional)

```bash
# Download and install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f  # Fix any dependency issues
```

### Step 7: Enable Flutter Web Support

```bash
# Enable web support
flutter config --enable-web

# Verify
flutter devices
# Should show Chrome and web-server as available devices
```

## Verification Checklist

After completing all steps, run `flutter doctor -v` and verify:

- ✓ Flutter (Channel stable)
- ✓ Android toolchain - develop for Android devices
- ✓ Chrome - develop for the web
- ✓ Linux toolchain - develop for Linux desktop (optional)

Expected output example:
```
[✓] Flutter (Channel stable, 3.x.x, on Linux, locale en_US.UTF-8)
[✓] Android toolchain - develop for Android devices (Android SDK version 33.x.x)
[✓] Chrome - develop for the web
[!] Android Studio (not installed)  # OK if using command-line tools
```

## Development Tools (Optional but Recommended)

### Visual Studio Code with Flutter Extension

```bash
# Install VS Code
sudo snap install code --classic

# Install Flutter extension
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

### Android Emulator Setup

```bash
# Install emulator
sdkmanager "emulator"
sdkmanager "system-images;android-33;google_apis;x86_64"

# Create emulator
avdmanager create avd -n gzclp_emulator -k "system-images;android-33;google_apis;x86_64"

# Run emulator
emulator -avd gzclp_emulator
```

## Troubleshooting

### Issue: "cmdline-tools component is missing"

**Solution:**
```bash
# Reorganize cmdline-tools directory
cd ~/Android/Sdk/cmdline-tools
mkdir latest
mv bin latest/
mv lib latest/
```

### Issue: "Android licenses not accepted"

**Solution:**
```bash
flutter doctor --android-licenses
# Answer 'y' to all prompts
```

### Issue: Flutter commands not found after installation

**Solution:**
```bash
# Verify PATH is set
echo $PATH | grep flutter

# If not present, add to ~/.bashrc
export PATH="$HOME/flutter/bin:$PATH"
source ~/.bashrc
```

### Issue: KVM permission denied (for emulator)

**Solution:**
```bash
# Add your user to kvm group
sudo adduser $USER kvm
# Log out and log back in
```

## Next Steps After Installation

Once `flutter doctor` shows no critical issues:

1. Return to the project directory:
   ```bash
   cd /home/camilo/projects/gzclp
   ```

2. Initialize the Flutter project:
   ```bash
   flutter create --org com.gzclp --project-name gzclp_tracker .
   ```

3. Verify the project works:
   ```bash
   flutter run -d chrome
   ```

## Quick Reference Commands

```bash
# Check Flutter version
flutter --version

# Check device availability
flutter devices

# Run on Chrome
flutter run -d chrome

# Run on Android emulator
flutter run

# Run tests
flutter test

# Build APK
flutter build apk

# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Generate code (for Drift)
dart run build_runner build

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs
```

## Resources

- **Flutter Documentation:** https://docs.flutter.dev/
- **Drift Documentation:** https://drift.simonbinder.eu/
- **BLoC Pattern:** https://bloclibrary.dev/
- **Flutter Cookbook:** https://docs.flutter.dev/cookbook
- **Android Developer:** https://developer.android.com/

---

**Installation Status:** Not Started
**Last Updated:** 2025-10-31
