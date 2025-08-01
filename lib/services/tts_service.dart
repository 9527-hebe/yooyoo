import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voice_model.dart';

class TTSService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<Voice>> getVoices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/voices'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((voice) => Voice.fromJson(voice))
              .toList();
        }
      }
      throw Exception('获取语音列表失败');
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }

  static Future<String> convertTextToSpeech(TTSRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return 'http://localhost:3000${data['data']['audioUrl']}';
        }
      }
      throw Exception('语音合成失败');
    } catch (e) {
      throw Exception('网络错误: $e');
    }
  }
}