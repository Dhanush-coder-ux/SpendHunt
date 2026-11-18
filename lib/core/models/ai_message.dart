enum MessageSender {
  user,
  assistant,
}

class AIMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? followUps;
  final Map<String, dynamic>? metadata;

  AIMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.followUps,
    this.metadata,
  });
}
