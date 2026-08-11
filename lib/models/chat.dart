class Chat {
  final String peerId;
  final String peerName;
  final String? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastSeen;

  const Chat({
    required this.peerId,
    required this.peerName,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastSeen,
  });

  Chat copyWith({
    String? peerId,
    String? peerName,
    String? lastMessage,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Chat(
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => {
    'peerId': peerId,
    'peerName': peerName,
    'lastMessage': lastMessage,
    'unreadCount': unreadCount,
    'isOnline': isOnline,
    'lastSeen': lastSeen?.toIso8601String(),
  };

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    peerId: json['peerId'] as String,
    peerName: json['peerName'] as String,
    lastMessage: json['lastMessage'] as String?,
    unreadCount: (json['unreadCount'] as int?) ?? 0,
    isOnline: (json['isOnline'] as bool?) ?? false,
    lastSeen: json['lastSeen'] != null
        ? DateTime.parse(json['lastSeen'] as String)
        : null,
  );
}
