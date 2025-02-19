import 'package:flutter/services.dart';
import 'package:personal_project/utils/debug_mode_print.dart';

class AudioUtils {
  static const MethodChannel _channel = MethodChannel('audio_utils');

  /// Expects [filePath] to be a local file path.
  static Future<int?> getAudioDuration(String filePath) async {
    try {
      // The native code returns duration in milliseconds.
      final int? duration = await _channel.invokeMethod('getAudioDuration', {
        'filePath': filePath,
      });
      return duration;
    } catch (e) {
      debugModePrint("Error getting audio duration: $e");
      return null;
    }
  }
}
