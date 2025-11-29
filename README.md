# android_sms_kit

A powerful Flutter plugin for reading SMS messages on Android devices. This plugin provides easy-to-use APIs for accessing SMS inbox, filtering transaction messages, and managing SMS permissions.

## Features

- ✅ Check and request SMS read permissions
- 📱 Read all SMS messages from inbox
- 💰 Filter transaction/bank SMS messages automatically
- 🎯 Get simplified SMS data with custom limits
- 🔒 Secure permission handling with proper Android lifecycle management
- 📊 Returns data in easy-to-parse JSON format

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅ Yes  |
| iOS      | ❌ No   |

**Note:** SMS reading is only available on Android. iOS does not provide APIs for reading SMS messages due to platform restrictions.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  android_sms_kit: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Android Setup

### Required: Add Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml` file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions inside manifest tag, before application tag -->
    <uses-permission android:name="android.permission.READ_SMS"/>
    <uses-permission android:name="android.permission.RECEIVE_SMS"/>
    
    <application
        android:label="your_app_name"
        android:icon="@mipmap/ic_launcher">
        <!-- Your app configuration -->
    </application>
</manifest>
```

**Important Notes:**
- Both `READ_SMS` and `RECEIVE_SMS` permissions are required
- Add these permissions **inside** the `<manifest>` tag
- Add them **before** the `<application>` tag
- These are dangerous permissions and require runtime permission request (handled by the plugin)

### Min SDK Version

Ensure your `android/app/build.gradle` has minimum SDK version 21 or higher:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // ...
    }
}
```

## Usage

### Import the package

```dart
import 'package:android_sms_kit/android_sms_kit.dart';
```

### Initialize the plugin

```dart
final _androidSmsKitPlugin = AndroidSmsKit();
```

### Check SMS Permission Status

```dart
String? permissionStatus = await _androidSmsKitPlugin.checkSmsPermission();
// Returns: "granted", "denied", or "notDetermined"
```

### Request SMS Permission

```dart
String? result = await _androidSmsKitPlugin.requestSmsPermission();
// Returns: "granted" or "denied"

if (result == 'granted') {
  print('Permission granted!');
} else {
  print('Permission denied');
}
```

### Read All SMS Messages

Reads up to 100 recent SMS messages from inbox:

```dart
String? jsonString = await _androidSmsKitPlugin.readSms();
List<Map<String, dynamic>> messages = _androidSmsKitPlugin.parseSmsJson(jsonString);

for (var message in messages) {
  print('From: ${message['address']}');
  print('Body: ${message['body']}');
  print('Date: ${message['date']}');
  print('Type: ${message['type']}');
}
```

### Get Simple SMS (with custom limit)

Get simplified SMS data with a custom message limit:

```dart
String? jsonString = await _androidSmsKitPlugin.getSimpleSms(limit: 50);
List<Map<String, dynamic>> messages = _androidSmsKitPlugin.parseSmsJson(jsonString);

for (var message in messages) {
  print('Sender: ${message['sender']}');
  print('Message: ${message['message']}');
  print('Timestamp: ${message['timestamp']}');
}
```

### Get Transaction SMS (Filtered)

Automatically filters and returns only bank/transaction-related SMS messages:

```dart
String? jsonString = await _androidSmsKitPlugin.getTransactionSms();
List<Map<String, dynamic>> transactions = _androidSmsKitPlugin.parseSmsJson(jsonString);

for (var transaction in transactions) {
  print('Bank: ${transaction['address']}');
  print('Details: ${transaction['body']}');
  print('Date: ${transaction['date']}');
}
```

## Transaction SMS Filtering

The plugin automatically filters transaction SMS based on common keywords:

- **Financial Keywords**: debited, credited, paid, received, transferred, withdrawn, deposit
- **Entity Keywords**: bank, account, upi, card, atm, transaction, payment, purchase
- **Currency Keywords**: amount, rupees, rs, inr, ₹
- **Amount Patterns**: Detects currency symbols followed by numbers (₹1234, Rs.1234, INR 1234)

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:android_sms_kit/android_sms_kit.dart';

class SmsReaderScreen extends StatefulWidget {
  @override
  _SmsReaderScreenState createState() => _SmsReaderScreenState();
}

class _SmsReaderScreenState extends State<SmsReaderScreen> {
  final _androidSmsKitPlugin = AndroidSmsKit();
  List<Map<String, dynamic>> _messages = [];
  String _permissionStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await _androidSmsKitPlugin.checkSmsPermission();
    setState(() {
      _permissionStatus = status ?? 'Unknown';
    });
  }

  Future<void> _requestPermission() async {
    final result = await _androidSmsKitPlugin.requestSmsPermission();
    setState(() {
      _permissionStatus = result ?? 'Unknown';
    });
  }

  Future<void> _readTransactionSms() async {
    if (_permissionStatus != 'granted') {
      await _requestPermission();
      return;
    }

    final jsonString = await _androidSmsKitPlugin.getTransactionSms();
    final messages = _androidSmsKitPlugin.parseSmsJson(jsonString);
    
    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SMS Reader')),
      body: Column(
        children: [
          Text('Permission: $_permissionStatus'),
          ElevatedButton(
            onPressed: _requestPermission,
            child: Text('Request Permission'),
          ),
          ElevatedButton(
            onPressed: _readTransactionSms,
            child: Text('Read Transaction SMS'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['address'] ?? ''),
                  subtitle: Text(message['body'] ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `getPlatformVersion()` | `Future<String?>` | Get Android platform version |
| `checkSmsPermission()` | `Future<String?>` | Check SMS permission status |
| `requestSmsPermission()` | `Future<String?>` | Request SMS read permission |
| `readSms()` | `Future<String?>` | Read all SMS (limit 100) |
| `getSimpleSms({int limit})` | `Future<String?>` | Get simplified SMS with custom limit |
| `getTransactionSms()` | `Future<String?>` | Get filtered transaction SMS |
| `parseSmsJson(String?)` | `List<Map<String, dynamic>>` | Parse JSON string to List |

### Data Models

#### Full SMS Object
```dart
{
  'address': 'String',    // Sender phone number/name
  'body': 'String',       // SMS message content
  'date': 'int',          // Timestamp in milliseconds
  'type': 'int'           // SMS type (1: inbox, 2: sent, etc.)
}
```

#### Simple SMS Object
```dart
{
  'sender': 'String',     // Sender phone number/name
  'message': 'String',    // SMS message content
  'timestamp': 'int'      // Timestamp in milliseconds
}
```

## Permissions

This plugin requires the following Android permission:
- `READ_SMS` - To read SMS messages from the device

**Important:** Starting from Android 6.0 (API level 23), you need to request dangerous permissions at runtime. This plugin handles the permission request flow for you.

## Privacy & Security

- Always inform users why you need SMS access
- Request permission only when necessary
- Follow Google Play Store policies regarding SMS permissions
- Handle sensitive SMS data securely
- Consider user privacy when filtering or storing SMS data

## Known Limitations

- Only works on Android platform
- Requires READ_SMS permission
- Transaction filtering works best with English SMS messages
- Maximum 500 SMS messages scanned for transaction filtering

## Troubleshooting

### Permission denied on first launch
The plugin correctly returns "notDetermined" before the first permission request. Call `requestSmsPermission()` to show the permission dialog.

### Empty results
Ensure SMS permission is granted before reading messages. Check permission status with `checkSmsPermission()`.

### Transaction SMS not detected
The plugin uses keyword-based filtering. Some bank SMS might use different terminology. You can customize filtering logic in your app.

### App crashes or permission errors
**Solution:** Verify that both permissions are added to your AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
```

### Permission request dialog doesn't appear
1. Check that permissions are declared in AndroidManifest.xml
2. Ensure you're testing on Android 6.0 (API 23) or higher
3. Try uninstalling and reinstalling the app
4. Check logcat for permission-related errors

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Issues and Feedback

Please file issues, bugs, or feature requests in our [issue tracker](https://github.com/yourusername/android_sms_kit/issues).

## Author

Created and maintained by [Your Name]

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes.

