import 'package:flutter/services.dart';
import 'sms_flutter_platform_interface.dart';

class MethodChannelSmsFlutter extends SmsFlutterPlatform {
  final MethodChannel _channel = MethodChannel('sms.receiver.channel');

  @override
  Future<int> getSimCount() async {
    final simCount = await _channel.invokeMethod<int>('get_sim_count');
    return simCount ?? 0;
  }

  @override
  Future<String> sendSmsWithSim({
    required String phoneNumber,
    required String message,
    int simSlot = 0,
  }) async {
    final result = await _channel.invokeMethod<String>('send_sms_with_sim', {
      'phone_number': phoneNumber,
      'message': message,
      'sim_slot': simSlot,
    });
    return result ?? 'Failed to send';
  }

  @override
  Future<Map<String, String>> receiveSms() async {
    final result = await _channel.invokeMethod<Map>('receive_sms');
    return Map<String, String>.from(result ?? {});
  }

  @override
  Future<bool> checkPermissions() async {
    final result = await _channel.invokeMethod<bool>('check_permissions');
    return result ?? false;
  }

  @override
  Future<void> requestPermissions() async {
    await _channel.invokeMethod('request_permissions');
  }
}
