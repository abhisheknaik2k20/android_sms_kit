import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'android_sms_kit_method_channel.dart';

abstract class AndroidSmsKitPlatform extends PlatformInterface {
  /// Constructs a AndroidSmsKitPlatform.
  AndroidSmsKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static AndroidSmsKitPlatform _instance = MethodChannelAndroidSmsKit();

  /// The default instance of [AndroidSmsKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelAndroidSmsKit].
  static AndroidSmsKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AndroidSmsKitPlatform] when
  /// they register themselves.
  static set instance(AndroidSmsKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<String?> checkSmsPermission() {
    throw UnimplementedError('checkSmsPermission() has not been implemented.');
  }

  Future<String?> requestSmsPermission() {
    throw UnimplementedError(
      'requestSmsPermission() has not been implemented.',
    );
  }

  Future<String?> readSms() {
    throw UnimplementedError('readSms() has not been implemented.');
  }

  Future<String?> getSimpleSms(int limit) {
    throw UnimplementedError('getSimpleSms() has not been implemented.');
  }

  Future<String?> getTransactionSms() {
    throw UnimplementedError('getTransactionSms() has not been implemented.');
  }
}
