import 'dart:convert';
import 'android_sms_kit_platform_interface.dart';

/// A Flutter plugin for reading SMS messages on Android devices.
///
/// **Important:** This plugin requires the following permissions in your AndroidManifest.xml:
/// ```xml
/// <uses-permission android:name="android.permission.READ_SMS"/>
/// <uses-permission android:name="android.permission.RECEIVE_SMS"/>
/// ```
///
/// Add these permissions inside the <manifest> tag but outside the <application> tag.
class AndroidSmsKit {
  Future<String?> getPlatformVersion() {
    return AndroidSmsKitPlatform.instance.getPlatformVersion();
  }

  Future<String?> checkSmsPermission() {
    return AndroidSmsKitPlatform.instance.checkSmsPermission();
  }

  Future<String?> requestSmsPermission() {
    return AndroidSmsKitPlatform.instance.requestSmsPermission();
  }

  Future<String?> readSms() {
    return AndroidSmsKitPlatform.instance.readSms();
  }

  Future<String?> getSimpleSms({int limit = 100}) {
    return AndroidSmsKitPlatform.instance.getSimpleSms(limit);
  }

  Future<String?> getTransactionSms() {
    return AndroidSmsKitPlatform.instance.getTransactionSms();
  }

  List<Map<String, dynamic>> parseSmsJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
