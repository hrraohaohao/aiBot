import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';
import '../../http/models/chat_device_history_item.dart';
import '../../http/services/agent_service.dart';

// 消息类型枚举
enum MessageType {
  text,     // 文本消息
  voice,    // 语音消息
  warning,  // 警告消息
}

// 消息方向枚举
enum MessageDirection {
  send,     // 发送方（用户）
  receive,  // 接收方（机器人）
}

// 聊天消息模型
class ChatMessage {
  final String id;
  final String content;
  final DateTime time;
  final MessageType type;
  final MessageDirection direction;
  final bool hasWarning;
  final bool hasAudio; // 是否有音频
  final String audioId; // 音频ID

  ChatMessage({
    required this.id,
    required this.content,
    required this.time,
    required this.type,
    required this.direction,
    this.hasWarning = false,
    this.hasAudio = false,
    this.audioId = '',
  });
}

class ChatHistoryPage extends StatefulWidget {
  final String agentId;
  final String agentName;
  final String macAddress;
  
  const ChatHistoryPage({
    Key? key,
    required this.agentId,
    required this.agentName,
    required this.macAddress,
  }) : super(key: key);

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  // 是否正在加载
  bool _isLoading = true;
  
  // 选中的聊天对象
  String _selectedContact = '饺子';
  
  // 聊天对象列表
  final List<String> _contactList = ['饺子', '面包', '蛋糕', '小龙虾'];
  
  // 聊天记录列表
  late List<ChatMessage> _chatMessages;
  
  // 服务实例
  final AgentService _agentService = AgentService();
  
  @override
  void initState() {
    super.initState();
    // 初始化服务
    _agentService.init();
    // 加载聊天记录
    _loadChatHistory();
  }
  
  // 加载聊天记录
  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 如果有指定的macAddress，则使用设备聊天历史API
      if (widget.macAddress.isNotEmpty) {
        final response = await _agentService.getChatDeviceHistory(
          agentId: widget.agentId,
          macAddress: widget.macAddress,
        );
        
        if (response.success && response.data != null) {
          // 将API返回的数据转换为聊天消息格式
          setState(() {
            _chatMessages = _convertDeviceHistoryToChatMessages(response.data!);
            _isLoading = false;
          });
          return;
        } else {
          // API调用成功但没有数据
          setState(() {
            _chatMessages = [];
            _isLoading = false;
          });
          debugPrint('API返回成功但没有数据: ${response.message}');
          return;
        }
      } else {
        // 没有macAddress参数，获取智能体的所有聊天会话
        // 目前通过使用联系人选择器，但实际可能需要调用其他API
        // 这里可以添加通过agentId获取所有会话的API调用
        // 暂时显示空列表
        setState(() {
          _chatMessages = [];
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      // 处理API调用异常
      debugPrint('获取聊天历史记录失败: $e');
      setState(() {
        _chatMessages = [];
        _isLoading = false;
      });
      
      // 显示错误信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取聊天记录失败: $e')),
        );
      }
      return;
    }
  }
  
  // 将设备聊天历史记录转换为聊天消息格式
  List<ChatMessage> _convertDeviceHistoryToChatMessages(List<ChatDeviceHistoryItem> historyItems) {
    // 按照createdAt时间排序
    historyItems.sort((a, b) {
      try {
        final timeA = DateTime.parse(a.createdAt);
        final timeB = DateTime.parse(b.createdAt);
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0; // 如果解析失败，保持原顺序
      }
    });
    
    return historyItems.map((item) {
      // 根据chatType确定消息方向
      // chatType = "1"：用户消息，显示在右边
      // chatType = "2"：设备/智能体消息，显示在左边
      MessageDirection direction;
      String chatTypeString = item.getChatTypeString();
      
      switch (chatTypeString) {
        case "1":
          direction = MessageDirection.send; // 用户消息，显示在右侧
          break;
        case "2":
          direction = MessageDirection.receive; // 设备消息，显示在左侧
          break;
        default:
          // 如果chatType无法识别，根据内容判断方向
          direction = item.content.contains('警告') 
              ? MessageDirection.receive 
              : MessageDirection.send;
      }
      
      DateTime time;
      try {
        time = DateTime.parse(item.createdAt);
      } catch (e) {
        time = DateTime.now(); // 如果解析失败，使用当前时间
      }
      
      // 检查是否包含风险关键词，用于标记警告
      final bool hasWarning = item.riskKeywords != null && item.riskKeywords!.isNotEmpty;
      
      return ChatMessage(
        id: item.id.toString(),
        content: item.content,
        time: time,
        type: MessageType.text, // 所有消息类型都设为文本
        direction: direction,
        hasWarning: hasWarning,
        hasAudio: item.audioId != null && item.audioId!.isNotEmpty, // 添加hasAudio标记
        audioId: item.audioId ?? '', // 保存audioId用于播放
      );
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.macAddress.isNotEmpty 
              ? '聊天记录 - ${widget.agentName}'
              : '聊天记录',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // 当macAddress为空时才显示联系人选择器
          if (widget.macAddress.isEmpty)
            _buildContactSelector(),
          
          // 聊天记录
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildChatHistory(),
          ),
        ],
      ),
    );
  }
  
  // 构建联系人选择器
  Widget _buildContactSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedContact,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedContact = newValue;
                });
                // 加载所选联系人的聊天记录
                _loadChatHistory();
              }
            },
            items: _contactList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  // 构建聊天记录列表
  Widget _buildChatHistory() {
    return Stack(
      children: [
        // 聊天消息列表
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _chatMessages.length,
          itemBuilder: (context, index) {
            final message = _chatMessages[index];
            return _buildMessageItem(message);
          },
        ),
        
        // 底部警告提示
        if (_chatMessages.any((msg) => msg.hasWarning))
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF1F1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade400,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '2条新的警告',
                    style: TextStyle(
                      color: Color(0xFFF25B5B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  // 构建消息项
  Widget _buildMessageItem(ChatMessage message) {
    final bool isUserMessage = message.direction == MessageDirection.send;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设备头像（显示在左侧）
          if (!isUserMessage)
            _buildAvatar(
              '机',
              Colors.blue.shade300,
              Icons.smart_toy, // 使用机器人图标
            ),
            
          const SizedBox(width: 8),
          
          // 消息气泡
          Flexible(
            child: Column(
              crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 消息内容
                _buildMessageBubble(message),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 用户头像（显示在右侧）
          if (isUserMessage)
            _buildAvatar(
              '我',
              Colors.pink.shade300,
              Icons.person, // 使用人物图标
            ),
        ],
      ),
    );
  }
  
  // 构建头像
  Widget _buildAvatar(String text, Color color, IconData icon) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: color,
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
  
  // 构建消息气泡
  Widget _buildMessageBubble(ChatMessage message) {
    final bool isUserMessage = message.direction == MessageDirection.send;
    final Color bubbleColor = isUserMessage 
        ? const Color(0xFF5BAAFF)
        : const Color(0xFFF5F5F5);
    final Color textColor = isUserMessage ? Colors.white : Colors.black87;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: message.hasWarning ? const Color(0xFFFE7875) : bubbleColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 如果有音频，显示播放图标在文字前面
          if (message.hasAudio)
            GestureDetector(
              onTap: () {
                // 这里可以添加播放音频的逻辑
                debugPrint('播放音频: ${message.audioId}');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: isUserMessage ? Colors.white : Colors.blue,
                  size: 20,
                ),
              ),
            ),
            
          // 消息文本内容
          Flexible(
            child: Text(
              message.content,
              style: TextStyle(
                color: message.hasWarning ? Colors.white : textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 