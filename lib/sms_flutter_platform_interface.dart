import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sms_flutter_plus/sms_flutter_method_channel.dart';

abstract class SmsFlutterPlatform extends PlatformInterface {
  /// Constructs a SmsFlutterPlatform.
  SmsFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmsFlutterPlatform _instance = MethodChannelSmsFlutter();

  /// The default instance of [SmsFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmsFlutter].
  static SmsFlutterPlatform get instance => _instance;

  /// Set the instance of [SmsFlutterPlatform] to use.
  static set instance(SmsFlutterPlatform instance) {
    _instance = instance;
  }

  Future<int> getSimCount();

  Future<String> sendSmsWithSim({
    required String phoneNumber,
    required String message,
    int simSlot,
  });

  Future<Map<String, String>> receiveSms();

  Future<bool> checkPermissions();

  Future<void> requestPermissions();
}
