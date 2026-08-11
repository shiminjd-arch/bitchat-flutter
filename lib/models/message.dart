enum MessageType { text, image, file, cashu }

enum EncryptionStatus { none, e2e, nostr }

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final EncryptionStatus encryptionStatus;

  const Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.encryptionStatus = EncryptionStatus.e2e,
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    EncryptionStatus? encryptionStatus,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      encryptionStatus: encryptionStatus ?? this.encryptionStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'encryptionStatus': encryptionStatus.name,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    senderId: json['senderId'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    type: MessageType.values.byName(json['type'] as String),
    encryptionStatus:
        EncryptionStatus.values.byName(json['encryptionStatus'] as String),
  );
}
