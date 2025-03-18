import 'package:flutter_test/flutter_test.dart';
import 'package:sms_flutter_plus/sms_flutter_platform_interface.dart';
import 'package:sms_flutter_plus/sms_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmsFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SmsFlutterPlatform {

  @override
  Future<int> getSimCount() {
    // TODO: implement getSimCount
    throw UnimplementedError();
  }


  @override
  Future<bool> checkPermissions() {
    // TODO: implement checkPermissions
    throw UnimplementedError();
  }

  @override
  Future<void> requestPermissions() {
    // TODO: implement requestPermissions
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> receiveSms() {
    // TODO: implement receiveSms
    throw UnimplementedError();
  }

  @override
  Future<String> sendSmsWithSim({required String phoneNumber, required String message, int? simSlot}) {
    // TODO: implement sendSmsWithSim
    throw UnimplementedError();
  }
}

void main() {
  final SmsFlutterPlatform initialPlatform = SmsFlutterPlatform.instance;

  test('$MethodChannelSmsFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmsFlutter>());
  });
}
