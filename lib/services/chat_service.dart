import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/chat.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _uuid = const Uuid();

  final List<Chat> _chats = [];
  final Map<String, List<Message>> _messages = {};

  static const _mockChats = [
    ('alice_001', 'Alice', '晚上见～', 3, true),
    ('bob_002', 'Bob', '收到，OK', 0, false),
    ('dark_ghost', 'DarkGhost', '密钥已交换 ✓', 1, true),
    ('crypto_cat', 'CryptoCat', null, 0, false),
    ('nostr_bridge', 'NostrBridge', '[图片]', 2, true),
  ];

  static final _now = DateTime.now();

  List<Chat> get chats => List.unmodifiable(_chats);

  void initMockData() {
    if (_chats.isNotEmpty) return;

    for (final (peerId, name, msg, unread, online) in _mockChats) {
      _chats.add(Chat(
        peerId: peerId,
        peerName: name,
        lastMessage: msg,
        unreadCount: unread,
        isOnline: online,
        lastSeen: online ? null : _now.subtract(const Duration(minutes: 5)),
      ));
      _messages[peerId] = [
        Message(
          id: _uuid.v4(),
          senderId: peerId,
          content: 'Hi，匿匿 上见',
          timestamp: _now.subtract(const Duration(hours: 2)),
        ),
        Message(
          id: _uuid.v4(),
          senderId: 'me',
          content: '好的，密钥已就绪',
          timestamp: _now.subtract(const Duration(hours: 1)),
        ),
      ];
    }
  }

  List<Message> getMessages(String peerId) {
    return List.unmodifiable(_messages[peerId] ?? []);
  }

  Future<Message> sendMessage({
    required String peerId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    // TODO: 后续接入 Rust bridge 走 E2EE + Tor/Nostr
    final msg = Message(
      id: _uuid.v4(),
      senderId: 'me',
      content: content,
      timestamp: DateTime.now(),
      type: type,
      encryptionStatus: EncryptionStatus.e2e,
    );

    _messages.putIfAbsent(peerId, () => []).add(msg);

    final idx = _chats.indexWhere((c) => c.peerId == peerId);
    if (idx >= 0) {
      _chats[idx] = _chats[idx].copyWith(lastMessage: content);
    }

    return msg;
  }

  void clearChat(String peerId) {
    _messages.remove(peerId);
    final idx = _chats.indexWhere((c) => c.peerId == peerId);
    if (idx >= 0) {
      _chats[idx] = _chats[idx].copyWith(lastMessage: null);
    }
  }
}
