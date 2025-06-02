import 'package:flutter/cupertino.dart';

import 'api_service.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/agent_model.dart';
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
}
