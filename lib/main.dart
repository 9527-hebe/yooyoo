import 'package:flutter/material.dart';
import 'screens/tts_screen.dart';

void main() {
  runApp(const TTSApp());
}

class TTSApp extends StatelessWidget {
  const TTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS多角色语音合成',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TTSScreen(),
    );
  }
}