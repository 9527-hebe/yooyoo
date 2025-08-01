import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/voice_model.dart';
import '../services/tts_service.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Voice> _roles = [];
  Voice? _selectedRole;
  String _selectedLanguage = 'zh-CN';
  bool _isLoading = false;
  bool _isPlaying = false;
  
  double _speed = 150;
  double _pitch = 50;
  double _volume = 100;

  // 支持的语言列表
  final List<Map<String, String>> _languages = [
    {'code': 'zh-CN', 'name': '中文（简体）'},
    {'code': 'zh-TW', 'name': '中文（繁体）'},
    {'code': 'en-US', 'name': 'English (US)'},
    {'code': 'en-GB', 'name': 'English (UK)'},
    {'code': 'ja-JP', 'name': '日本語'},
    {'code': 'ko-KR', 'name': '한국어'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await TTSService.getVoices();
      setState(() {
        _roles = roles;
        _selectedRole = roles.isNotEmpty ? roles.first : null;
        if (_selectedRole != null) {
          _speed = _selectedRole!.speed.toDouble();
          _pitch = _selectedRole!.pitch.toDouble();
          _volume = _selectedRole!.volume.toDouble();
        }
      });
    } catch (e) {
      _showError('加载角色列表失败: $e');
    }
  }

  Future<void> _convertToSpeech() async {
    if (_textController.text.isEmpty || _selectedRole == null) {
      _showError('请输入文本并选择角色');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = TTSRequest(
        text: _textController.text,
        role: _selectedRole!.id,
        language: _selectedLanguage,
        speed: _speed.round(),
        pitch: _pitch.round(),
        volume: _volume.round(),
      );

      final audioUrl = await TTSService.convertTextToSpeech(request);
      await _audioPlayer.play(UrlSource(audioUrl));
      
      setState(() => _isPlaying = true);
    } catch (e) {
      _showError('语音合成失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onRoleChanged(Voice? role) {
    if (role != null) {
      setState(() {
        _selectedRole = role;
        _speed = role.speed.toDouble();
        _pitch = role.pitch.toDouble();
        _volume = role.volume.toDouble();
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 构建文本输入区域
  Widget _buildTextInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '最大字符数 1000',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '剩余 ${1000 - _textController.text.length} 可用',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 12,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: '请输入要转换为语音的文本...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              counterText: '',
            ),
            onChanged: (text) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // 构建控制面板
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 语言选择
          const Text(
            '语言',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              underline: const SizedBox(),
              items: _languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Text(
                    language['name']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 角色选择
          const Text(
            '角色',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          
          // 角色列表
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                final isSelected = _selectedRole?.id == role.id;
                
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey.shade400,
                      child: Text(
                        role.name.substring(0, 1),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      role.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      role.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onTap: () => _onRoleChanged(role),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 语音参数调节
          const Text(
            '语音参数',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          
          // 语速
          Text('语速: ${_speed.round()}'),
          Slider(
            value: _speed,
            min: 80,
            max: 300,
            divisions: 22,
            activeColor: Colors.blue,
            onChanged: (value) => setState(() => _speed = value),
          ),
          
          // 音调
          Text('音调: ${_pitch.round()}'),
          Slider(
            value: _pitch,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: Colors.blue,
            onChanged: (value) => setState(() => _pitch = value),
          ),
          
          // 音量
          Text('音量: ${_volume.round()}'),
          Slider(
            value: _volume,
            min: 0,
            max: 200,
            divisions: 20,
            activeColor: Colors.blue,
            onChanged: (value) => setState(() => _volume = value),
          ),
          
          const SizedBox(height: 24),
          
          // 转换按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _convertToSpeech,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '转换为语音',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'TTSMAKER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Free Text to Speech',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('简体中文'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Pro Upgrade'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 响应式布局：大屏左右布局，小屏上下布局
          if (constraints.maxWidth > 768) {
            // 大屏幕：左右布局
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧：文本输入区域
                  Expanded(
                    flex: 2,
                    child: _buildTextInputSection(),
                  ),
                  const SizedBox(width: 24),
                  // 右侧：控制面板
                  Expanded(
                    flex: 1,
                    child: _buildControlPanel(),
                  ),
                ],
              ),
            );
          } else {
            // 小屏幕：上下布局
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextInputSection(),
                  const SizedBox(height: 16),
                  _buildControlPanel(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _textController.dispose();
    super.dispose();
  }
}