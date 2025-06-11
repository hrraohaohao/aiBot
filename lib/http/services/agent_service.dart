import 'package:flutter/cupertino.dart';

import 'api_service.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/agent_model.dart';
import '../models/device_model.dart';
import '../models/agent_template_model.dart';
import '../../utils/token_manager.dart';

class AgentService extends ApiService {
  // 单例模式
  static final AgentService _instance = AgentService._internal();

  factory AgentService() => _instance;

  AgentService._internal();

  // API端点
  static const String _baseUrl = 'https://admin.chat-ai.cc';
  static const String _agent = '/xiaozhi/mobile/agent'; //创建智能体
  static const String _agentList = '/xiaozhi/mobile/agent/list'; //智能体列表
  static const String _BindBot = '/xiaozhi/device/bind'; //绑定设备
  static const String _getBindBotList = '/xiaozhi/device/bind'; //获取已绑定的设备
  static const String _unbindBot = '/xiaozhi/device/unbind'; //解绑设备
  static const String _agentTemplate = '/xiaozhi/mobile/agent/template'; //智能体模板模板列表
  static const String _agentDetail = '/xiaozhi/mobile/agent'; //智能体详情

  // 初始化
  Future<void> init() async {
    setBaseUrl(_baseUrl);
    
    // 获取并设置token
    final token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      setToken(token);
    }
  }

  //创建智能体
  Future<ApiResponse<String>> agent({
    required String agentName,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    final Map<String, dynamic> data = {
      'agentName': agentName,
    };
    final response = await post<String>(
      _agent,
      data: data,
      fromJson: (json) => json.toString(),
    );
    return response;
  }
  
  // 获取智能体列表
  Future<ApiResponse<List<AgentModel>>> getAgentList() async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    final response = await get<List<AgentModel>>(
      _agentList,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => AgentModel.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => AgentModel.fromJson(item)).toList();
        }
        return [];
      },
    );
    return response;
  }
  
  // 获取智能体模板列表
  Future<ApiResponse<List<AgentTemplateModel>>> getAgentTemplateList() async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    final response = await get<List<AgentTemplateModel>>(
      _agentTemplate,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => AgentTemplateModel.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => AgentTemplateModel.fromJson(item)).toList();
        }
        return [];
      },
    );
    
    // 在返回前记录一下数据便于调试
    if (response.success && response.data != null) {
      debugPrint('获取到${response.data!.length}个智能体模板');
    }
    
    return response;
  }
  
  // 获取智能体模板详情
  Future<ApiResponse<AgentTemplateModel>> getAgentTemplateDetail(String templateId) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    final String path = '$_agentTemplate/$templateId';
    
    final response = await get<AgentTemplateModel>(
      path,
      fromJson: (json) => AgentTemplateModel.fromJson(json),
    );
    
    return response;
  }
  
  // 绑定设备
  Future<ApiResponse<dynamic>> bindBot({
    required String agentId,
    required String deviceCode,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 构建PATH参数
    final String path = '$_BindBot/$agentId/$deviceCode';
    
    // 发送POST请求
    final response = await post<dynamic>(
      path,
      fromJson: (json) => json,
    );
    
    return response;
  }
  
  // 获取已绑定的设备列表
  Future<ApiResponse<List<DeviceModel>>> getBindBotList({
    required String agentId,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 构建PATH参数
    final String path = '$_getBindBotList/$agentId';
    
    // 发送GET请求
    final response = await get<List<DeviceModel>>(
      path,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => DeviceModel.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => DeviceModel.fromJson(item)).toList();
        }
        return [];
      },
    );
    
    return response;
  }
  
  // 解绑设备
  Future<ApiResponse<dynamic>> unbindBot({
    required String deviceId,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 请求数据
    final Map<String, dynamic> data = {
      'deviceId': deviceId,
    };
    
    // 发送POST请求
    final response = await post<dynamic>(
      _unbindBot,
      data: data,
      fromJson: (json) => json,
    );
    
    return response;
  }
  
  // 获取智能体详情
  Future<ApiResponse<AgentModel>> getAgentDetail(String agentId) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 构建PATH参数
    final String path = '$_agentDetail/$agentId';
    
    // 发送GET请求
    final response = await get<AgentModel>(
      path,
      fromJson: (json) => AgentModel.fromJson(json),
    );
    
    return response;
  }
}
