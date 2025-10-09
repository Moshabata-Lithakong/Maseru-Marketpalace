class ChatRoom {
  final String id;
  final String participantId;
  final String participantName;
  final String participantRole; // 'vendor' or 'taxi_driver'
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantRole,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isSentByMe;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
  });
}