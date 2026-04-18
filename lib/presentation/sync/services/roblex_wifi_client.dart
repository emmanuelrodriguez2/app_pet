import 'dart:convert';

import 'package:http/http.dart' as http;

class RoblexWifiClient {
  const RoblexWifiClient();

  Uri _buildUri(String host, String path) {
    final normalized = host.trim();
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      final base = Uri.parse(normalized);
      return base.replace(path: path);
    }
    return Uri.parse('http://$normalized$path');
  }

  Future<bool> testConnection(String host) async {
    final uri = _buildUri(host, '/');
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    return response.statusCode >= 200 && response.statusCode < 500;
  }

  Future<void> sendRgb({
    required String host,
    required int red,
    required int green,
    required int blue,
  }) async {
    final path =
        '/?r${red.clamp(0, 255)}g${green.clamp(0, 255)}b${blue.clamp(0, 255)}&';
    final uri = _buildUri(host, path);
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw Exception('Error HTTP ${response.statusCode}');
    }
  }

  Future<void> sendRawCommand({
    required String host,
    required String command,
  }) async {
    final query = Uri.encodeComponent(command.trim());
    final uri = _buildUri(host, '/?cmd=$query');
    final response = await http.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw Exception('Error HTTP ${response.statusCode}');
    }
  }

  Future<void> dispenseNow({required String host, int grams = 80}) async {
    final safeGrams = grams.clamp(1, 500);
    await sendRawCommand(host: host, command: 'dispense:$safeGrams');
  }

  Future<void> setSchedule({
    required String host,
    required int slot,
    required String hhmm,
    int grams = 80,
  }) async {
    final safeSlot = slot.clamp(1, 9);
    final safeGrams = grams.clamp(1, 500);
    await sendRawCommand(
      host: host,
      command: 'schedule:$safeSlot:$hhmm:$safeGrams',
    );
  }

  String buildRoblexInfo({required String host, required bool connected}) {
    final data = {
      'host': host,
      'connected': connected,
      'protocol': 'HTTP GET',
      'example': '/?r201g32b255&',
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
