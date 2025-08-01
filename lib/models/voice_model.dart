class Voice {
  final String id;
  final String name;
  final String description;
  final String voice;
  final int speed;
  final int pitch;
  final int volume;

  Voice({
    required this.id,
    required this.name,
    required this.description,
    required this.voice,
    required this.speed,
    required this.pitch,
    required this.volume,
  });

  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      voice: json['voice'],
      speed: json['speed'],
      pitch: json['pitch'],
      volume: json['volume'],
    );
  }
}

class TTSRequest {
  final String text;
  final String role;
  final String language;
  final int speed;
  final int pitch;
  final int volume;

  TTSRequest({
    required this.text,
    required this.role,
    this.language = 'zh-CN',
    this.speed = 150,
    this.pitch = 50,
    this.volume = 100,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'role': role,
      'language': language,
      'speed': speed,
      'pitch': pitch,
      'volume': volume,
    };
  }
}