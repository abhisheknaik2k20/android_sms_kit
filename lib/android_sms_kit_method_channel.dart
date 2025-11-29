import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'android_sms_kit_platform_interface.dart';

/// An implementation of [AndroidSmsKitPlatform] that uses method channels.
class MethodChannelAndroidSmsKit extends AndroidSmsKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('android_sms_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<String?> checkSmsPermission() async {
    final status = await methodChannel.invokeMethod<String>(
      'checkSmsPermission',
    );
    return status;
  }

  @override
  Future<String?> requestSmsPermission() async {
    final result = await methodChannel.invokeMethod<String>(
      'requestSmsPermission',
    );
    return result;
  }

  @override
  Future<String?> readSms() async {
    final messages = await methodChannel.invokeMethod<String>('readSms');
    return messages;
  }

  @override
  Future<String?> getSimpleSms(int limit) async {
    final messages = await methodChannel.invokeMethod<String>('getSimpleSms', {
      'limit': limit,
    });
    return messages;
  }

  @override
  Future<String?> getTransactionSms() async {
    final messages = await methodChannel.invokeMethod<String>(
      'getTransactionSms',
    );
    return messages;
  }
}
