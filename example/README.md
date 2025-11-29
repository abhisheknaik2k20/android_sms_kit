# android_sms_kit_example

Demonstrates how to use the android_sms_kit plugin.

## Features Demonstrated

This example app showcases all the features of the android_sms_kit plugin:

### 1. Permission Management
- Check current SMS permission status
- Request SMS read permission from user
- Display permission status with visual indicators

### 2. SMS Reading Modes

#### All SMS
- Read up to 100 recent SMS messages
- Display complete SMS data including sender, message body, date, and type

#### Simple SMS
- Fetch simplified SMS data with custom limit (default: 50)
- Lightweight data structure for better performance

#### Transaction SMS
- Automatically filter bank/transaction messages
- Smart keyword-based detection
- Scans up to 500 messages for transactions

### 3. User Interface
- Material Design 3 implementation
- Three-tab interface for different SMS types
- Real-time message counts
- Loading indicators
- Error handling with snackbar notifications
- Responsive card-based message display

## Getting Started

### Prerequisites

Make sure you have Flutter installed and set up for Android development.

### Required: AndroidManifest.xml Setup

**Before running the example**, ensure the following permissions are added to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.READ_SMS"/>
    <uses-permission android:name="android.permission.RECEIVE_SMS"/>
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

✅ These permissions are **already included** in the example app's AndroidManifest.xml

### Running the Example

1. Clone the repository
2. Navigate to the example directory:
   ```bash
   cd example
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### First Time Setup

When you first launch the app:

1. The app will check SMS permission status (shows as "NOT DETERMINED")
2. Tap "Request Permission" button
3. Grant SMS read permission when prompted
4. Now you can use all three SMS reading buttons

## Screenshots

### Permission Request
The app properly handles Android runtime permissions with clear UI feedback.

### SMS Display
Messages are displayed in an easy-to-read card format showing:
- Sender name/number
- Message content (truncated if too long)
- Date and time
- Message type indicator

### Tab Navigation
Switch between:
- **All SMS Tab**: Complete SMS data with all fields
- **Simple Tab**: Lightweight SMS view
- **Transactions Tab**: Filtered bank/payment messages only

## Code Structure

```
lib/
└── main.dart          # Main application with all examples
```

### Key Components

#### Permission Handling
```dart
Future<void> checkPermission() async {
  final status = await _androidSmsKitPlugin.checkSmsPermission();
  setState(() => _permissionStatus = status ?? 'Unknown');
}

Future<void> requestPermission() async {
  final result = await _androidSmsKitPlugin.requestSmsPermission();
  // Handle result...
}
```

#### Reading SMS
```dart
// All SMS
final jsonString = await _androidSmsKitPlugin.readSms();

// Simple SMS with limit
final jsonString = await _androidSmsKitPlugin.getSimpleSms(limit: 50);

// Transaction SMS only
final jsonString = await _androidSmsKitPlugin.getTransactionSms();

// Parse results
final messages = _androidSmsKitPlugin.parseSmsJson(jsonString);
```

## Testing

### Manual Testing Steps

1. **Permission Test**
   - Launch app → Check shows "NOT DETERMINED"
   - Tap Request → System dialog appears
   - Grant permission → Status shows "GRANTED"

2. **SMS Reading Test**
   - Tap "All SMS" → Loads recent messages
   - Tap "Simple SMS" → Loads simplified data
   - Tap "Transactions" → Shows only bank SMS

3. **Error Handling Test**
   - Deny permission → Error message shown
   - Try reading without permission → Warning displayed

### Expected Behavior

- Permission requests show Android system dialog
- Denied permission shows appropriate error messages
- Granted permission enables all SMS reading buttons
- Messages load with loading indicator
- Empty results show helpful empty state
- Errors display in snackbar notifications

## Common Issues

### No messages appear
- Ensure SMS permission is granted
- Check that your device has SMS messages
- Verify you're connected to a real device (not emulator without SMS)

### Permission always denied
- Check AndroidManifest.xml includes READ_SMS permission
- Ensure targeting Android API 23 or higher
- Try clearing app data and reinstalling

### Transaction SMS empty
- Only messages matching keywords are shown
- Ensure you have bank/payment SMS on device
- Check message language (works best with English)

## Building for Release

To build a release version:

```bash
flutter build apk --release
```

Or for app bundle:

```bash
flutter build appbundle --release
```

## Learn More

For more information about using the plugin, see:
- [Plugin Documentation](../README.md)
- [API Reference](../README.md#api-reference)
- [Flutter Documentation](https://flutter.dev)

## Support

If you encounter issues:
1. Check the main README troubleshooting section
2. Review Android logcat output
3. File an issue on GitHub with details

## License

This example app is included with the android_sms_kit plugin and follows the same MIT License.
