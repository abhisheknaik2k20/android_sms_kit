# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2024-01-XX

### 🎉 Initial Release

#### Added
- **SMS Permission Management**
  - Check SMS permission status (`checkSmsPermission`)
  - Request SMS read permission at runtime (`requestSmsPermission`)
  - Proper Android lifecycle handling with ActivityAware

- **SMS Reading Features**
  - Read all SMS messages from inbox (up to 100 messages)
  - Get simplified SMS data with customizable limit
  - Automatic transaction SMS filtering with keyword detection

- **Transaction SMS Detection**
  - Intelligent filtering based on 20+ financial keywords
  - Currency pattern recognition (₹, Rs, INR)
  - Detects debited, credited, paid, received, transferred, payment keywords
  - Bank, UPI, card, and ATM transaction detection

- **Data Parsing**
  - JSON response format for all SMS data
  - Built-in JSON parser utility (`parseSmsJson`)
  - Type-safe data models

- **Platform Support**
  - Full Android support (API 21+)
  - ActivityAware implementation for proper permission handling
  - Null-safety support

#### Features Breakdown

**Permission Methods:**
- `checkSmsPermission()` - Returns: "granted", "denied", or "notDetermined"
- `requestSmsPermission()` - Shows system permission dialog

**Reading Methods:**
- `readSms()` - Returns up to 100 recent SMS messages
- `getSimpleSms(limit: int)` - Returns simplified SMS with custom limit (default: 100)
- `getTransactionSms()` - Returns filtered transaction/bank SMS (scans up to 500 messages)

**Helper Methods:**
- `parseSmsJson(String?)` - Converts JSON string to List<Map<String, dynamic>>
- `getPlatformVersion()` - Returns Android version

#### Technical Details
- Minimum Android SDK: 21 (Android 5.0 Lollipop)
- Target Android SDK: 34
- Kotlin implementation
- Uses Android ContentResolver for SMS access
- Thread-safe permission handling
- Proper error handling and null-safety
- **Required Permissions**: READ_SMS and RECEIVE_SMS

#### Data Structures

**Full SMS Format:**
```json
{
  "address": "BANK-NAME",
  "body": "Rs.1000 debited from account",
  "date": 1234567890000,
  "type": 1
}
```

**Simple SMS Format:**
```json
{
  "sender": "BANK-NAME",
  "message": "Rs.1000 debited from account",
  "timestamp": 1234567890000
}
```

#### Transaction Keywords Detected
- **Transaction Types**: debited, credited, paid, received, transferred, withdrawn, deposit
- **Financial Entities**: bank, account, balance, transaction, payment, purchase
- **Payment Methods**: upi, card, atm
- **Currency Terms**: amount, rupees, rs, inr, ₹

#### Example App
- Comprehensive demo application included
- Shows all plugin features
- Material Design 3 UI
- Three-tab interface for different SMS types
- Permission management examples
- Error handling demonstrations

### Dependencies
- Flutter SDK: ">=3.5.4 <4.0.0"
- Android embedding v2
- Kotlin support

### Documentation
- Complete README with usage examples
- API reference documentation
- Privacy and security guidelines
- Troubleshooting section

### Notes
- iOS platform not supported (platform limitation)
- **Requires READ_SMS and RECEIVE_SMS permissions in AndroidManifest.xml**
- Follows Android runtime permission best practices
- Complies with Google Play Store SMS permission policies

---

## Upcoming Features (Planned)

### [0.1.0] - Future Release
- [ ] SMS sent folder reading
- [ ] SMS drafts reading
- [ ] Search SMS by keyword
- [ ] Date range filtering
- [ ] Enhanced transaction amount extraction
- [ ] Multi-language transaction keyword support
- [ ] SMS deletion support (with WRITE_SMS permission)

### [0.2.0] - Future Release
- [ ] SMS backup and restore
- [ ] Export SMS to JSON/CSV
- [ ] Custom transaction keyword configuration
- [ ] SMS categorization (personal, promotional, transactional)
- [ ] SMS statistics and analytics

---

**Note:** This is the first release. Please report any issues or feature requests on the [GitHub repository](https://github.com/yourusername/android_sms_kit/issues).

### Migration Guide
N/A - Initial release

### Breaking Changes
N/A - Initial release

### Deprecations
N/A - Initial release
