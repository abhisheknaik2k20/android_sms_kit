import 'package:flutter_test/flutter_test.dart';
import 'package:android_sms_kit/android_sms_kit.dart';
import 'package:android_sms_kit/android_sms_kit_platform_interface.dart';
import 'package:android_sms_kit/android_sms_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAndroidSmsKitPlatform
    with MockPlatformInterfaceMixin
    implements AndroidSmsKitPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> checkSmsPermission() => Future.value('granted');

  @override
  Future<String?> requestSmsPermission() => Future.value('granted');

  @override
  Future<String?> readSms() => Future.value(
    '[{"address":"1234567890","body":"Test message","date":1234567890000,"type":1}]',
  );

  @override
  Future<String?> getSimpleSms(int limit) => Future.value(
    '[{"sender":"1234567890","message":"Test message","timestamp":1234567890000}]',
  );

  @override
  Future<String?> getTransactionSms() => Future.value(
    '[{"address":"BANK","body":"Rs.100 debited from your account","date":1234567890000,"type":1}]',
  );
}

void main() {
  final AndroidSmsKitPlatform initialPlatform = AndroidSmsKitPlatform.instance;

  test('$MethodChannelAndroidSmsKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAndroidSmsKit>());
  });

  test('getPlatformVersion', () async {
    AndroidSmsKit androidSmsKitPlugin = AndroidSmsKit();
    MockAndroidSmsKitPlatform fakePlatform = MockAndroidSmsKitPlatform();
    AndroidSmsKitPlatform.instance = fakePlatform;

    expect(await androidSmsKitPlugin.getPlatformVersion(), '42');
  });

  group('SMS Permission Tests', () {
    late AndroidSmsKit androidSmsKitPlugin;
    late MockAndroidSmsKitPlatform fakePlatform;

    setUp(() {
      androidSmsKitPlugin = AndroidSmsKit();
      fakePlatform = MockAndroidSmsKitPlatform();
      AndroidSmsKitPlatform.instance = fakePlatform;
    });

    test('checkSmsPermission returns granted', () async {
      final result = await androidSmsKitPlugin.checkSmsPermission();
      expect(result, 'granted');
    });

    test('requestSmsPermission returns granted', () async {
      final result = await androidSmsKitPlugin.requestSmsPermission();
      expect(result, 'granted');
    });
  });

  group('SMS Reading Tests', () {
    late AndroidSmsKit androidSmsKitPlugin;
    late MockAndroidSmsKitPlatform fakePlatform;

    setUp(() {
      androidSmsKitPlugin = AndroidSmsKit();
      fakePlatform = MockAndroidSmsKitPlatform();
      AndroidSmsKitPlatform.instance = fakePlatform;
    });

    test('readSms returns valid JSON string', () async {
      final result = await androidSmsKitPlugin.readSms();
      expect(result, isNotNull);
      expect(result, contains('address'));
      expect(result, contains('body'));
    });

    test('getSimpleSms returns valid JSON string', () async {
      final result = await androidSmsKitPlugin.getSimpleSms(limit: 50);
      expect(result, isNotNull);
      expect(result, contains('sender'));
      expect(result, contains('message'));
    });

    test('getTransactionSms returns valid JSON string', () async {
      final result = await androidSmsKitPlugin.getTransactionSms();
      expect(result, isNotNull);
      expect(result, contains('debited'));
    });
  });

  group('SMS Parsing Tests', () {
    late AndroidSmsKit androidSmsKitPlugin;

    setUp(() {
      androidSmsKitPlugin = AndroidSmsKit();
    });

    test('parseSmsJson returns empty list for null input', () {
      final result = androidSmsKitPlugin.parseSmsJson(null);
      expect(result, isEmpty);
    });

    test('parseSmsJson returns empty list for empty string', () {
      final result = androidSmsKitPlugin.parseSmsJson('');
      expect(result, isEmpty);
    });

    test('parseSmsJson returns empty list for invalid JSON', () {
      final result = androidSmsKitPlugin.parseSmsJson('invalid json');
      expect(result, isEmpty);
    });

    test('parseSmsJson correctly parses valid JSON', () {
      const jsonString =
          '[{"sender":"1234567890","message":"Test","timestamp":1234567890000}]';
      final result = androidSmsKitPlugin.parseSmsJson(jsonString);

      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result[0]['sender'], '1234567890');
      expect(result[0]['message'], 'Test');
      expect(result[0]['timestamp'], 1234567890000);
    });

    test('parseSmsJson handles multiple SMS messages', () {
      const jsonString = '''
      [
        {"sender":"1111111111","message":"Message 1","timestamp":1111111111111},
        {"sender":"2222222222","message":"Message 2","timestamp":2222222222222}
      ]
      ''';
      final result = androidSmsKitPlugin.parseSmsJson(jsonString);

      expect(result.length, 2);
      expect(result[0]['sender'], '1111111111');
      expect(result[1]['sender'], '2222222222');
    });
  });

  group('Edge Cases', () {
    late AndroidSmsKit androidSmsKitPlugin;
    late MockAndroidSmsKitPlatform fakePlatform;

    setUp(() {
      androidSmsKitPlugin = AndroidSmsKit();
      fakePlatform = MockAndroidSmsKitPlatform();
      AndroidSmsKitPlatform.instance = fakePlatform;
    });

    test('getSimpleSms with default limit', () async {
      final result = await androidSmsKitPlugin.getSimpleSms();
      expect(result, isNotNull);
    });

    test('parseSmsJson handles nested objects', () {
      const jsonString =
          '[{"sender":"TEST","message":"Hello","timestamp":123,"extra":{"nested":"value"}}]';
      final result = androidSmsKitPlugin.parseSmsJson(jsonString);

      expect(result, isNotEmpty);
      expect(result[0]['sender'], 'TEST');
      expect(result[0]['extra'], isA<Map>());
    });
  });
}
