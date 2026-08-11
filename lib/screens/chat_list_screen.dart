import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _bgColor = Color(0xFF0D1117);
const _surfaceColor = Color(0xFF161B22);
const _primaryColor = Color(0xFF4A90D9);
const _borderColor = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);
const _onlineGreen = Color(0xFF3FB950);

final _searchQueryProvider = StateProvider<String>((ref) => '');

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(_searchQueryProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        title: const Text('匿匿',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: _textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) =>
                  ref.read(_searchQueryProvider.notifier).state = v,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: '搜索聊天...',
                hintStyle:
                    const TextStyle(color: _textSecondary, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: _textSecondary, size: 20),
                filled: true,
                fillColor: _surfaceColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryColor),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: _chats.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _chats.length,
                    itemBuilder: (_, i) => _buildChatItem(_chats[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: _textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('还没有聊天',
              style: TextStyle(color: _textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('点击右下角按钮发起新对话',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildChatItem(_ChatPreview chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _primaryColor.withValues(alpha: 0.2),
                      child: Text(
                        chat.name[0].toUpperCase(),
                        style: const TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                    if (chat.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: _onlineGreen,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _onlineGreen,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: _bgColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chat.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(chat.lastMessage,
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),

                // Meta
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(chat.time,
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 11)),
                    const SizedBox(height: 6),
                    if (chat.unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${chat.unread}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatPreview {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;

  const _ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.isOnline = false,
  });
}

const _chats = <_ChatPreview>[
  _ChatPreview(
      name: 'Alice',
      lastMessage: '收到，晚上聊 🤙',
      time: '14:32',
      unread: 3,
      isOnline: true),
  _ChatPreview(
      name: 'Bob',
      lastMessage: '那个PR我review完了',
      time: '13:15',
      unread: 0,
      isOnline: false),
  _ChatPreview(
      name: '匿匿AI助手',
      lastMessage: '你好！有什么可以帮你的？',
      time: '昨天',
      unread: 0,
      isOnline: true),
  _ChatPreview(
      name: 'Crypto 群组',
      lastMessage: 'Charlie: 有没有人用过Cashu？',
      time: '昨天',
      unread: 99,
      isOnline: false),
  _ChatPreview(
      name: 'David',
      lastMessage: '[图片]',
      time: '周一',
      unread: 1,
      isOnline: false),
];
