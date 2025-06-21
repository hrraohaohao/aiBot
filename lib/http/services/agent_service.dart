import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/agent_model.dart';
import '../models/device_model.dart';
import '../models/agent_template_model.dart';
import '../../utils/token_manager.dart';
import '../models/model_name_item.dart';
import '../models/model_voice_item.dart';
import '../models/agent_detail_model.dart';
import '../models/agent_update_request.dart';
import '../models/agent_session_item.dart';
import '../models/chat_session_item.dart';
import '../models/chat_device_history_item.dart';

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
  static const String _modelsName = '/xiaozhi/models/names'; //获取模型名称
  static const String _modelsVoices = '/xiaozhi/models/{modelId}/voices'; //获取音色名称

  static const String _agentPut = '/xiaozhi/agent/{id}'; //更新智能体
  static const String _agentSessions = '/xiaozhi/mobile/agent/{id}/sessions'; // 智能体会话列表
  static const String _chatSessions = '/xiaozhi/mobile/agent/{id}/session/{sessionId}'; // 获取聊天会话内容

  static const String _chatDeviceHistory = '/xiaozhi/mobile/agent/device/chat-history'; // 获取设备的聊天会话内容

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
  Future<ApiResponse<AgentDetailModel>> getAgentDetail(String agentId) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 构建PATH参数
    final String path = '$_agentDetail/$agentId';
    
    // 发送GET请求
    final response = await get<AgentDetailModel>(
      path,
      fromJson: (json) => AgentDetailModel.fromJson(json),
    );
    
    return response;
  }
  
  // 获取模型名称列表
  Future<ApiResponse<List<ModelNameItem>>> getModelsName({
    String? modelType,
    String? modelName,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 构建查询参数
    final Map<String, dynamic> queryParameters = {};
    if (modelType != null) {
      queryParameters['modelType'] = modelType;
    }
    if (modelName != null) {
      queryParameters['modelName'] = modelName;
    }
    
    // 发送GET请求
    final response = await get<List<ModelNameItem>>(
      _modelsName,
      queryParameters: queryParameters,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => ModelNameItem.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => ModelNameItem.fromJson(item)).toList();
        }
        return [];
      },
    );
    
    // 在返回前记录一下数据便于调试
    if (response.success && response.data != null) {
      debugPrint('获取到${response.data!.length}个模型名称');
    }
    
    return response;
  }
  
  // 获取模型音色列表
  Future<ApiResponse<List<ModelVoiceItem>>> getModelVoices({
    required String modelId,
    String? name,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 替换路径中的模型ID
    final String path = _modelsVoices.replaceAll('{modelId}', modelId);
    
    // 构建查询参数
    final Map<String, dynamic> queryParameters = {};
    if (name != null) {
      queryParameters['name'] = name;
    }
    
    // 发送GET请求
    final response = await get<List<ModelVoiceItem>>(
      path,
      queryParameters: queryParameters,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => ModelVoiceItem.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => ModelVoiceItem.fromJson(item)).toList();
        }
        return [];
      },
    );
    
    // 在返回前记录一下数据便于调试
    if (response.success && response.data != null) {
      debugPrint('获取到${response.data!.length}个模型音色');
    }
    
    return response;
  }
  
  // 更新智能体
  Future<ApiResponse<dynamic>> updateAgent({
    required String agentId,
    required AgentUpdateRequest request,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 替换路径中的ID
    final String path = _agentPut.replaceAll('{id}', agentId);
    
    // 使用Dio发送PUT请求
    final dio = this.dio;
    dio.options.headers['content-type'] = 'application/json';
    
    try {
      final dioResponse = await dio.put(
        path,
        data: request.toJson(),
      );
      
      // 处理响应
      if (dioResponse.statusCode == 200 || dioResponse.statusCode == 201) {
        final responseData = dioResponse.data;
        
        // 处理成功响应
        if (responseData is Map) {
          final code = responseData['code'];
          if (code != null && code != 200 && code != 0) {
            // 业务逻辑错误
            return ApiResponse<dynamic>(
              success: false,
              code: code,
              message: responseData['msg'] ?? responseData['message'] ?? '未知错误',
            );
          }
          
          // 成功响应
          return ApiResponse<dynamic>(
            success: true,
            code: code ?? 200,
            message: responseData['msg'] ?? responseData['message'] ?? 'Success',
            data: responseData['data'],
          );
        }
        
        // 直接返回响应数据
        return ApiResponse<dynamic>(
          success: true,
          message: 'Success',
          data: responseData,
        );
      } else {
        // 非成功状态码
        return ApiResponse<dynamic>(
          success: false,
          code: dioResponse.statusCode ?? 500,
          message: '请求失败，状态码: ${dioResponse.statusCode}',
        );
      }
    } catch (e) {
      // 请求异常
      return ApiResponse<dynamic>(
        success: false,
        code: e is DioError ? e.response?.statusCode ?? 500 : 500,
        message: e is DioError ? e.message ?? '未知错误' : e.toString(),
      );
    }
  }

  // 获取智能体会话列表
  Future<ApiResponse<List<AgentSessionItem>>> getAgentSessions({
    required String agentId,
    int? page,
    int limit = 20,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 替换路径中的ID
    final String path = _agentSessions.replaceAll('{id}', agentId);
    
    // 构建查询参数
    final Map<String, dynamic> queryParameters = {
      'limit': limit,
    };
    
    if (page != null) {
      queryParameters['page'] = page;
    }
    
    // 发送GET请求
    final response = await get<List<AgentSessionItem>>(
      path,
      queryParameters: queryParameters,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => AgentSessionItem.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => AgentSessionItem.fromJson(item)).toList();
        }
        return [];
      },
    );
    
    return response;
  }

  // 获取聊天会话内容
  Future<ApiResponse<List<ChatSessionItem>>> getChatSessions({
    required String id,
    required String sessionId,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 替换路径中的参数
    String path = _chatSessions.replaceAll('{id}', id);
    path = path.replaceAll('{sessionId}', sessionId);
    
    // 发送GET请求
    final response = await get<List<ChatSessionItem>>(
      path,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => ChatSessionItem.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => ChatSessionItem.fromJson(item)).toList();
        }
        return [];
      },
    );
    
    return response;
  }
  
  // 获取设备的聊天历史记录
  Future<ApiResponse<List<ChatDeviceHistoryItem>>> getChatDeviceHistory({
    required String agentId,
    required String macAddress,
  }) async {
    // 确保每次请求前都添加Authorization头
    addAuthorizationHeader();
    
    // 请求数据
    final Map<String, dynamic> data = {
      'agentId': agentId,
      'macAddress': macAddress,
    };
    
    // 发送POST请求
    final response = await post<List<ChatDeviceHistoryItem>>(
      _chatDeviceHistory,
      data: data,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => ChatDeviceHistoryItem.fromJson(item)).toList();
        }
        // 如果返回的是对象中包含list字段的情况
        if (json is Map && json.containsKey('list')) {
          final list = json['list'] as List;
          return list.map((item) => ChatDeviceHistoryItem.fromJson(item)).toList();
        }
        return [];
      },
    );
    
    // 在返回前记录一下数据便于调试
    if (response.success && response.data != null) {
      debugPrint('获取到${response.data!.length}条设备聊天历史记录');
    }
    
    return response;
  }
}
