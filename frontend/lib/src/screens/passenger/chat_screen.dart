import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maseru_marketplace/src/providers/auth_provider.dart';
import 'package:maseru_marketplace/src/models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  void _loadChatRooms() {
    // Simulate loading chat rooms
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _chatRooms.addAll([
          ChatRoom(
            id: '1',
            participantId: 'vendor1',
            participantName: 'Bakery Shop',
            participantRole: 'vendor',
            lastMessage: 'Your bread order is ready for pickup!',
            lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
            unreadCount: 2,
          ),
          ChatRoom(
            id: '2',
            participantId: 'taxi1',
            participantName: 'John Taxi',
            participantRole: 'taxi_driver',
            lastMessage: 'I\'m on my way to pickup your order',
            lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
            unreadCount: 0,
          ),
          ChatRoom(
            id: '3',
            participantId: 'vendor2',
            participantName: 'Electronics Store',
            participantRole: 'vendor',
            lastMessage: 'Your phone case is available',
            lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
            unreadCount: 1,
          ),
        ]);
        _isLoading = false;
      });
    });
  }

  void _startNewChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.store, color: Colors.orange),
              title: const Text('Chat with Vendor'),
              subtitle: const Text('Discuss products and orders'),
              onTap: () {
                Navigator.pop(context);
                _navigateToVendorList();
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_taxi, color: Colors.green),
              title: const Text('Chat with Taxi Driver'),
              subtitle: const Text('Coordinate deliveries'),
              onTap: () {
                Navigator.pop(context);
                _navigateToTaxiDriverList();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToVendorList() {
    // Navigate to vendor list for chatting
    // You can implement this later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vendor list feature coming soon!')),
    );
  }

  void _navigateToTaxiDriverList() {
    // Navigate to taxi driver list for chatting
    // You can implement this later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Taxi driver list feature coming soon!')),
    );
  }

  void _openChat(ChatRoom chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(chatRoom: chatRoom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: _startNewChat,
            tooltip: 'Start new chat',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = _chatRooms[index];
                    return _buildChatListItem(chatRoom);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No chats yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation with vendors or taxi drivers',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startNewChat,
            icon: const Icon(Icons.add_comment),
            label: const Text('Start New Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(ChatRoom chatRoom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(chatRoom.participantRole),
          child: Icon(
            _getRoleIcon(chatRoom.participantRole),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Text(
              chatRoom.participantName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(chatRoom.participantRole).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getRoleColor(chatRoom.participantRole)),
              ),
              child: Text(
                chatRoom.participantRole == 'vendor' ? 'Vendor' : 'Taxi Driver',
                style: TextStyle(
                  color: _getRoleColor(chatRoom.participantRole),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          chatRoom.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(chatRoom.lastMessageTime),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (chatRoom.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chatRoom.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(chatRoom),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'vendor':
        return Colors.orange;
      case 'taxi_driver':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'vendor':
        return Icons.store;
      case 'taxi_driver':
        return Icons.local_taxi;
      default:
        return Icons.person;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${time.day}/${time.month}';
  }
}

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({super.key, required this.chatRoom});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Simulate loading messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: widget.chatRoom.participantId,
        senderName: widget.chatRoom.participantName,
        content: 'Hello! How can I help you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isSentByMe: false,
      ),
      ChatMessage(
        id: '2',
        senderId: 'current_user',
        senderName: 'You',
        content: 'I have a question about my order',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isSentByMe: true,
      ),
      ChatMessage(
        id: '3',
        senderId: widget.chatRoom.participantId,
        senderName: widget.chatRoom.participantName,
        content: widget.chatRoom.lastMessage,
        timestamp: widget.chatRoom.lastMessageTime,
        isSentByMe: false,
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      content: _messageController.text,
      timestamp: DateTime.now(),
      isSentByMe: true,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatRoom.participantName),
            Text(
              widget.chatRoom.participantRole == 'vendor' ? 'Vendor' : 'Taxi Driver',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages.reversed.toList()[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isSentByMe)
            CircleAvatar(
              backgroundColor: _getRoleColor(widget.chatRoom.participantRole),
              child: Icon(
                _getRoleIcon(widget.chatRoom.participantRole),
                color: Colors.white,
                size: 16,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isSentByMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isSentByMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isSentByMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'vendor':
        return Colors.orange;
      case 'taxi_driver':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'vendor':
        return Icons.store;
      case 'taxi_driver':
        return Icons.local_taxi;
      default:
        return Icons.person;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}