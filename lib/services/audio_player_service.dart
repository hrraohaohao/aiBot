import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';

/// 音频播放服务 - 使用audioplayers 4.1.0
class AudioPlayerService {
  // 单例模式
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();
  
  // 音频播放器实例
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // UUID生成器
  final Uuid _uuid = const Uuid();
  
  // 当前播放的音频ID
  String? _currentAudioId;
  
  // 播放完成回调
  Function? onPlayComplete;
  
  // 获取当前播放的音频ID
  String? get currentAudioId => _currentAudioId;
  
  // 获取播放状态
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;
  
  // 初始化
  Future<void> init() async {
    debugPrint('AudioPlayerService初始化(audioplayers 4.1.0)');
    
    // 设置播放完成监听
    _audioPlayer.onPlayerComplete.listen((_) {
      debugPrint('音频播放完成: $_currentAudioId');
      _currentAudioId = null;
      
      // 调用播放完成回调
      if (onPlayComplete != null) {
        onPlayComplete!();
      }
    });
    
    // 设置播放状态监听
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('音频播放状态变化: $state');
    });
    
    // 在audioplayers 4.1.0中，错误处理方式不同
    // 我们将在播放方法中通过try-catch处理错误
  }
  
  // 从URL播放
  Future<bool> playFromUrl(String audioId, String url) async {
    try {
      debugPrint('播放音频URL: $url');
      
      // 如果有正在播放的音频，先停止
      if (_currentAudioId != null) {
        await stop();
      }
      
      // 设置音频源，添加必要的头信息
      // 对于audioplayers 4.1.0，我们需要使用setSourceUrl
      // 注意：audioplayers 4.1.0不支持自定义HTTP头，所以我们直接使用URL
      await _audioPlayer.setSourceUrl(url);
      
      // 开始播放
      await _audioPlayer.resume();
      
      // 记录当前播放的音频ID
      _currentAudioId = audioId;
      
      return true;
    } catch (e) {
      debugPrint('播放音频URL失败: $e');
      return false;
    }
  }
  
  // 从文件播放
  Future<bool> playFromFile(String audioId, String filePath) async {
    try {
      debugPrint('从文件播放音频: $filePath');
      
      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('音频文件不存在: $filePath');
        return false;
      }
      
      // 如果有正在播放的音频，先停止
      if (_currentAudioId != null) {
        await stop();
      }
      
      // 设置音频源为文件
      await _audioPlayer.setSourceDeviceFile(filePath);
      
      // 开始播放
      await _audioPlayer.resume();
      
      // 记录当前播放的音频ID
      _currentAudioId = audioId;
      
      return true;
    } catch (e) {
      debugPrint('从文件播放音频失败: $e');
      return false;
    }
  }
  
  // 从WAV原始数据播放
  Future<bool> playWavFromRawData(String audioId, Uint8List rawData) async {
    try {
      debugPrint('播放原始音频数据，数据长度: ${rawData.length}');
      
      // 如果有正在播放的音频，先停止
      if (_currentAudioId != null) {
        await stop();
      }
      
      // 设置音频源
      await _audioPlayer.setSourceBytes(rawData);
      
      // 开始播放
      await _audioPlayer.resume();
      
      // 记录当前播放的音频ID
      _currentAudioId = audioId;
      
      return true;
    } catch (e) {
      debugPrint('播放原始音频数据失败: $e');
      return false;
    }
  }
  
  // 暂停播放
  Future<void> pause() async {
    debugPrint('暂停音频播放');
    await _audioPlayer.pause();
  }
  
  // 恢复播放
  Future<void> resume() async {
    debugPrint('恢复音频播放');
    await _audioPlayer.resume();
  }
  
  // 停止播放
  Future<void> stop() async {
    debugPrint('停止音频播放');
    await _audioPlayer.stop();
    _currentAudioId = null;
  }
  
  // 释放资源
  Future<void> dispose() async {
    debugPrint('释放音频播放器资源');
    await _audioPlayer.dispose();
    _currentAudioId = null;
  }
} 