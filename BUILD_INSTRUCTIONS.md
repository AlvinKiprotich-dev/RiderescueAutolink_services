# RideRescue Services - Android App Bundle Build Instructions

This document provides instructions for building and uploading the RideRescue Services app as an Android App Bundle (.aab) to the Google Play Store.

## Prerequisites

- Flutter SDK installed and configured
- Android Studio with Android SDK
- Google Play Console account
- Keystore file (already created)

## Keystore Information

The upload keystore has been created with the following details:
- **Keystore file**: `android/app/upload-keystore.jks`
- **Alias**: `upload`
- **Store password**: `riderescue123`
- **Key password**: `riderescue123`

⚠️ **Important**: Keep this keystore file secure. If you lose it, you won't be able to update your app on Google Play Store.

## Building the AAB File

### Option 1: Using the build script (Recommended)

#### On Windows:
```bash
./build-aab.bat
```

#### On macOS/Linux:
```bash
chmod +x build-aab.sh
./build-aab.sh
```

### Option 2: Manual build

1. Clean the project:
   ```bash
   flutter clean
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Build the AAB:
   ```bash
   flutter build appbundle --release
   ```

## Build Output

The AAB file will be generated at:
```
build/app/outputs/bundle/release/app-release.aab
```

## Uploading to Google Play Store

1. **Sign in to Google Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Sign in with your Google account

2. **Create a new app (if first time)**
   - Click "Create app"
   - Fill in the app details:
     - App name: "RideRescue Services"
     - Default language: English
     - App or game: App
     - Free or paid: Free

3. **Upload the AAB file**
   - Go to "Production" track
   - Click "Create new release"
   - Upload the AAB file from `build/app/outputs/bundle/release/app-release.aab`
   - Add release notes
   - Save and review release

4. **Complete the store listing**
   - App content
   - Graphics (screenshots, feature graphic)
   - Categorization
   - Content rating
   - Privacy policy

5. **Submit for review**
   - Review all sections
   - Submit for review

## Troubleshooting

### Common Issues

1. **Build fails with signing errors**
   - Ensure the keystore file exists at `android/app/upload-keystore.jks`
   - Verify the passwords in `android/app/build.gradle.kts`

2. **AAB file too large**
   - Check for large assets in `assets/` folder
   - Consider using WebP format for images
   - Remove unused dependencies

3. **Google Play Console rejects the upload**
   - Ensure the app bundle is properly signed
   - Check that the version code is higher than the previous version
   - Verify all required permissions are declared in `android/app/src/main/AndroidManifest.xml`

### Version Management

To update the app version:

1. Update `version` in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # 1.0.1 is version name, 2 is version code
   ```

2. Rebuild the AAB file using the steps above

## Security Notes

- Keep the keystore file secure and backed up
- Don't commit the keystore file to version control
- Consider using environment variables for keystore passwords in production

## Support

If you encounter issues during the build or upload process, check:
1. Flutter documentation: https://flutter.dev/docs/deployment/android
2. Google Play Console help: https://support.google.com/googleplay/android-developer 