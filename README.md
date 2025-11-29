# Build Apps with Termux

In this tutorial, you'll learn how to build APKs with Termux, without needing Proot.

> [!NOTE]
> This guide assumes familiarity with Termux and Gradle basics. The steps below will help you get set up quickly.

After facing challenges in building apps and testing multiple methods, I've put together the best way to do it. You can use the automated setup script or follow the manual steps below.

## Quick Setup (Automated)

The fastest way to set up your build environment is using the automated setup script:

```bash
# Download and run the setup script
wget -O ~/termux-setup.sh https://raw.githubusercontent.com/illegalvoid/termux-build-apps/main/setup.sh
chmod +x ~/termux-setup.sh
bash ~/termux-setup.sh
```

After the script completes, restart your terminal or run:
```bash
source ~/.bashrc
```

The script will automatically:
- Update Termux packages
- Install Java 21 (latest LTS)
- Install Android SDK
- Accept SDK licenses
- Install Android Platform API 35
- Install Gradle 8.10.2 (latest stable)
- Configure aapt2 path
- Set up all environment variables

## Manual Setup

If you prefer to set things up manually, follow these steps:

### 1. Install Termux

[Termux](https://github.com/termux/termux-app/releases) is a powerful terminal app for Android, and it will serve as your development environment.

### 2. Install Required Packages

Before setting up the Android SDK, you'll need some essential packages in Termux. This tutorial uses `Java 21` (latest LTS version).

```bash
# First update & upgrade
pkg update -y && pkg upgrade -y
# Then install jdk and wget
pkg install wget openjdk-21 -y
```

> **Simple Check (JDK):**  
> To confirm Java is installed correctly, run:
> ```bash
> java -version
> ```
> It should output information about JDK version 21.

### 3. Install Android SDK

Next, we need the Android SDK. You can find setup in this [repository](https://github.com/Sohil876/termux-sdk-installer), or run the following commands directly:

```bash
# Download the installer script using wget and save it to the home directory
wget -O ~/install-android-sdk.sh https://raw.githubusercontent.com/Sohil876/termux-sdk-installer/main/installer.sh
# Make the script executable
chmod +x ~/install-android-sdk.sh
# Run the script with the install option
bash ~/install-android-sdk.sh -i
```

Once the SDK is installed, you'll see a new directory named `android-sdk` in your Termux files. This directory contains all necessary tools.

Before moving on, you must accept Google licenses:

```bash
yes | sdkmanager --licenses
```

Set the Android platform version to latest, which is `35` (Android 15):

```bash
yes | sdkmanager "platforms;android-35"
```

### 4. Install Gradle

You'll need Gradle `v8.10.2` (latest stable version), which is compatible with Java 21. Download and set it up as follows:

```bash
# Download Gradle
wget -O $ANDROID_HOME/gradle-8.10.2-bin.zip https://services.gradle.org/distributions/gradle-8.10.2-bin.zip
# Unzip it
unzip $ANDROID_HOME/gradle-8.10.2-bin.zip -d $ANDROID_HOME/
mv $ANDROID_HOME/gradle-8.10.2/ $ANDROID_HOME/gradle/
# Remove zip file (optional)
rm $ANDROID_HOME/gradle-8.10.2-bin.zip
# Add Gradle to your PATH
echo 'export PATH=${PATH}:${ANDROID_HOME}/gradle/bin' >> ~/.bashrc
source ~/.bashrc
```

Now you can run Gradle and the Android SDK for any task you need.

> **Simple Check (Gradle):**  
> To verify Gradle is working, run:
> ```bash
> gradle -v
> ```
> It should show version info such as: `Gradle 8.10.2`

### 5. Fix aapt2 Issue

There's a known issue with Gradle in Termux where it cannot find the `aapt2` build tool. To fix this, specify it in the global Gradle properties.

Go to the file `~/.gradle/gradle.properties` (create it if it doesn't exist) and add:

```properties
android.aapt2FromMavenOverride=/data/data/com.termux/files/home/android-sdk/build-tools/<version>/aapt2
```

Replace `<version>` with the actual version you have in your SDK (you can find it by running `ls ~/android-sdk/build-tools/`).

---

## Current Versions

- **Java:** OpenJDK 21 (LTS)
- **Gradle:** 8.10.2 (latest stable)
- **Android Platform:** API 35 (Android 15)
- **Build Tools:** Latest available via SDK Manager

## Troubleshooting

If you encounter any issues:

1. **Gradle daemon issues:** Run `gradle --stop` and try again
2. **Permission errors:** Make sure all scripts have execute permissions with `chmod +x`
3. **Path issues:** Ensure you've run `source ~/.bashrc` after installation
4. **Build failures:** Check that your project's `build.gradle` targets compatible SDK versions

---

**Congratulations!** You can now build Android apps using Termux, without Proot. Enjoy coding!
