import 'dart:async';

// 事件总线，用于应用内的全局事件通信
class EventBus {
  // 单例模式
  static final EventBus _instance = EventBus._internal();
  static EventBus get instance => _instance;
  EventBus._internal();
  
  // 创建一个流控制器，允许多个监听者
  final StreamController _streamController = StreamController.broadcast();
  
  // 发布事件
  void fire(dynamic event) {
    _streamController.add(event);
  }
  
  // 订阅事件流
  Stream get on => _streamController.stream;
  
  // 销毁控制器
  void dispose() {
    _streamController.close();
  }
}

// 定义各种事件
class AppEvent {}

// 未授权事件，用于处理401错误
class UnauthorizedEvent extends AppEvent {
  final String message;
  
  UnauthorizedEvent(this.message);
} 