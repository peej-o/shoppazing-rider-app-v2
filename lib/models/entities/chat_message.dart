class ChatMessage {
  final String id;
  final String senderUID;
  final String receiverUID;
  final String text;
  final DateTime timestamp;
  final String orderId;
  final String? imageUrl;
  final String messageType;

  ChatMessage({
    required this.id,
    required this.senderUID,
    required this.receiverUID,
    required this.text,
    required this.timestamp,
    required this.orderId,
    this.imageUrl,
    this.messageType = 'text',
  });

  Map<String, dynamic> toJson() {
    return {
      'senderUID': senderUID,
      'receiverUID': receiverUID,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'orderId': orderId,
      'imageUrl': imageUrl,
      'messageType': messageType,
    };
  }

  factory ChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return ChatMessage(
      id: id,
      senderUID: json['senderUID'] ?? '',
      receiverUID: json['receiverUID'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      orderId: json['orderId'] ?? '',
      imageUrl: json['imageUrl']?.toString(),
      messageType: json['messageType']?.toString() ?? 'text',
    );
  }
}
