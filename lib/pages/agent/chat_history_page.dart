import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';

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

  ChatMessage({
    required this.id,
    required this.content,
    required this.time,
    required this.type,
    required this.direction,
    this.hasWarning = false,
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
  
  // 聊天记录列表（模拟数据）
  late List<ChatMessage> _chatMessages;
  
  @override
  void initState() {
    super.initState();
    // 加载聊天记录
    _loadChatHistory();
  }
  
  // 加载聊天记录
  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟聊天记录数据
    final List<ChatMessage> messages = [
              ChatMessage(
          id: '1',
          content: '聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容',
          time: DateTime.now().subtract(const Duration(minutes: 15)),
          type: MessageType.text,
          direction: MessageDirection.send,
        ),
      ChatMessage(
        id: '2',
        content: '聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容',
        time: DateTime.now().subtract(const Duration(minutes: 14)),
        type: MessageType.text,
        direction: MessageDirection.receive,
      ),
      ChatMessage(
        id: '3',
        content: '聊天内容',
        time: DateTime.now().subtract(const Duration(minutes: 10)),
        type: MessageType.voice,
        direction: MessageDirection.send,
      ),
      ChatMessage(
        id: '4',
        content: '聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容聊天内容',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        type: MessageType.text,
        direction: MessageDirection.receive,
      ),
      ChatMessage(
        id: '5',
        content: '聊天内容',
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        type: MessageType.voice,
        direction: MessageDirection.send,
        hasWarning: true,
      ),
    ];
    
    setState(() {
      _chatMessages = messages;
      _isLoading = false;
    });
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
          // 接收方头像（机器人）
          if (!isUserMessage)
            _buildAvatar('小', Colors.blue.shade200),
            
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
          
          // 发送方头像（用户）
          if (isUserMessage)
            _buildAvatar('饺', Colors.pink.shade300),
        ],
      ),
    );
  }
  
  // 构建头像
  Widget _buildAvatar(String text, Color color) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: color,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
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
      padding: message.type == MessageType.voice
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 语音消息播放按钮
          if (message.type == MessageType.voice)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
            
          // 消息文本
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