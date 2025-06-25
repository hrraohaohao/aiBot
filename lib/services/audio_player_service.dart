import 'package:flutter/foundation.dart';

/// 音频播放服务 - 模拟版本
/// 完全不依赖任何音频播放库，仅提供模拟功能
class AudioPlayerService {
  // 单例模式
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();
  
  // 当前播放的音频ID
  String? _currentAudioId;
  
  // 播放状态
  bool _isPlaying = false;
  
  // 获取当前播放的音频ID
  String? get currentAudioId => _currentAudioId;
  
  // 获取播放状态
  bool get isPlaying => _isPlaying;
  
  // 初始化
  Future<void> init() async {
    debugPrint('AudioPlayerService初始化(模拟版本)');
  }
  
  // 从URL播放
  Future<bool> playFromUrl(String audioId, String url) async {
    debugPrint('模拟播放音频URL: $url');
    
    // 模拟版本，只记录状态
    _currentAudioId = audioId;
    _isPlaying = true;
    
    // 模拟3秒后播放完成
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentAudioId == audioId) {
        _isPlaying = false;
        _currentAudioId = null;
        debugPrint('模拟音频播放完成: $audioId');
      }
    });
    
    return true;
  }
  
  // 从WAV原始数据播放
  Future<bool> playWavFromRawData(String audioId, String rawData) async {
    debugPrint('模拟播放原始音频数据，数据长度: ${rawData.length}');
    
    // 模拟版本，只记录状态
    _currentAudioId = audioId;
    _isPlaying = true;
    
    // 模拟2秒后播放完成
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentAudioId == audioId) {
        _isPlaying = false;
        _currentAudioId = null;
        debugPrint('模拟原始音频播放完成: $audioId');
      }
    });
    
    return true;
  }
  
  // 暂停播放
  Future<void> pause() async {
    debugPrint('暂停音频播放');
    _isPlaying = false;
  }
  
  // 恢复播放
  Future<void> resume() async {
    debugPrint('恢复音频播放');
    _isPlaying = true;
  }
  
  // 停止播放
  Future<void> stop() async {
    debugPrint('停止音频播放');
    _currentAudioId = null;
    _isPlaying = false;
  }
  
  // 释放资源
  Future<void> dispose() async {
    debugPrint('释放音频播放器资源');
    _currentAudioId = null;
    _isPlaying = false;
  }
} 