# Firebase Authentication Setup Guide

This document explains how to configure Firebase for the gym app with authentication features.

## Prerequisites

1. A Firebase project (create one at [Firebase Console](https://console.firebase.google.com/))
2. Flutter SDK installed
3. Android Studio / Xcode for platform-specific configuration

## Firebase Console Configuration

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Follow the wizard to create your project

### 2. Enable Authentication Methods

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable the following providers:
   - **Phone** - For phone number authentication
   - **Google** - For Google Sign-In
   - **Facebook** - For Facebook Login (requires Facebook App ID and App Secret)

### 3. Configure Firestore Database

1. Go to **Firestore Database** in Firebase Console
2. Click "Create database"
3. Choose production or test mode
4. Select a location for your database
5. The `users` collection will be created automatically when the first user signs up

### 4. Configure Firebase Storage

**CRITICAL**: Firebase Storage must be enabled for profile photo uploads to work.

1. Go to **Storage** in Firebase Console
2. Click "Get Started"
3. Choose production mode or test mode
4. Select the same location as your Firestore database
5. Click "Done"

#### Firebase Storage Security Rules

**IMPORTANT**: Configure Storage rules to allow authenticated users to upload photos:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow users to upload and manage their own photos
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

To set these rules:
1. Go to Firebase Console > Storage > Rules
2. Replace the default rules with the above
3. Click "Publish"

#### Storage Structure

Profile photos are stored at: `users/{userId}/photos/profile_{timestamp}_{index}.jpg`

Example: `users/abc123/photos/profile_1234567890_0.jpg`

## Android Configuration

### 1. Register Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.rivalclub.app`
3. Download the `google-services.json` file
4. Replace the placeholder file at `android/app/google-services.json` with the downloaded file

### 2. SHA-1 Certificate

For Google Sign-In on Android, you need to add your SHA-1 certificate fingerprint:

**Debug Certificate:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Release Certificate:**
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your_alias
```

Add the SHA-1 fingerprint in Firebase Console under Project Settings > Your Android app.

### 3. Enable Firebase Services

The following have already been configured in `android/app/build.gradle`:
- Google Services plugin
- Firebase dependencies
- MultiDex support
- Minimum SDK version set to 21

## iOS Configuration

### 1. Register iOS App

1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.rivalclub.app`
3. Download the `GoogleService-Info.plist` file
4. Replace the placeholder file at `ios/Runner/GoogleService-Info.plist` with the downloaded file

### 2. Update Info.plist

Add the following to `ios/Runner/Info.plist` for URL schemes:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Replace `YOUR_CLIENT_ID` with the reversed client ID from `GoogleService-Info.plist`.

### 3. Update Podfile

The Podfile should already have the minimum iOS version set. If not, ensure it's at least iOS 12.0:

```ruby
platform :ios, '12.0'
```

## Google Sign-In Configuration

### Android
1. Add SHA-1 certificate as described above
2. The OAuth client will be created automatically in Firebase

### iOS
1. The reversed client ID will be used for URL schemes
2. Update `Info.plist` as described above

## Facebook Login Configuration

### 1. Create Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app
3. Add "Facebook Login" product

### 2. Configure Facebook App

1. Add your package name and class name in Facebook app settings
2. Add your Android key hash:
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
   ```

3. For iOS, add Bundle ID and enable Single Sign-On

### 3. Add Facebook Credentials to Firebase

1. In Firebase Console, go to Authentication > Sign-in method > Facebook
2. Enter your Facebook App ID and App Secret
3. Copy the OAuth redirect URI and add it to your Facebook app

## Testing

### Phone Authentication Testing

For testing without sending actual SMS:
1. Go to Firebase Console > Authentication > Sign-in method > Phone
2. Scroll down to "Phone numbers for testing"
3. Add test phone numbers with verification codes

Example:
- Phone: +1 555-555-5555
- Code: 123456

### Running the App

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Firestore Security Rules

Set up basic security rules for the `users` collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow users to read and write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow anyone to check if a phone number exists (for registration flow)
      allow read: if request.auth != null;
    }
  }
}
```

## Firebase Storage Rules

Set up security rules for Firebase Storage (see Configuration section above for details):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Make sure `google-services.json` and `GoogleService-Info.plist` are properly configured
2. **Google Sign-In fails**: Check SHA-1 certificate is added in Firebase Console
3. **Phone auth fails**: Ensure Phone authentication is enabled in Firebase Console
4. **Facebook login fails**: Verify Facebook App ID and Secret are correct in Firebase
5. **Photo upload fails with "object-not-found"**: 
   - Ensure Firebase Storage is enabled in Firebase Console
   - Check that Storage rules are configured correctly (see Configuration section)
   - Verify the default Storage bucket exists
6. **Photo upload fails with "unauthorized"**:
   - Check Firebase Storage rules allow write access for authenticated users
   - Verify the user is properly authenticated before uploading

### Debug Mode

The app includes error logging. Check the console for detailed error messages.

## Dependencies

The following Firebase dependencies are included in `pubspec.yaml`:

```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.3.4
cloud_firestore: ^5.5.2
firebase_storage: ^12.3.6
google_sign_in: ^6.2.3
flutter_facebook_auth: ^7.1.5
intl_phone_field: ^3.2.0
```

## Support

For more information, refer to:
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Facebook Login for Flutter](https://pub.dev/packages/flutter_facebook_auth)
