import 'package:flutter/foundation.dart';

void debugLog(String tag, String message) {
  if (!kDebugMode) return;
  debugPrint('[$tag] [${_timestamp()}] $message');
}

String _timestamp() {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}'
      '.${three(now.millisecond)}';
}
