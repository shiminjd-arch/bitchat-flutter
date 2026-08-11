import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _bgColor = Color(0xFF0D1117);
const _surfaceColor = Color(0xFF161B22);
const _primaryColor = Color(0xFF4A90D9);
const _borderColor = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);
const _onlineGreen = Color(0xFF3FB950);
const _bubbleMine = Color(0xFF1A3A5C);
const _bubbleOther = Color(0xFF21262D);

final _messageControllerProvider = Provider.autoDispose<TextEditingController>(
    (ref) => TextEditingController());
final _messagesProvider =
    StateProvider.autoDispose<List<_ChatMessage>>((ref) => _sampleMessages);
final _hasTextProvider = StateProvider.autoDispose<bool>((ref) => false);

class ChatScreen extends ConsumerStatefulWidget {
  final String peerId;
  final String peerName;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.peerId,
    this.peerName = '',
    this.isOnline = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_messagesProvider);
    final hasText = ref.watch(_hasTextProvider);
    final controller = ref.watch(_messageControllerProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _primaryColor.withValues(alpha: 0.2),
              child: Text(
                widget.peerName[0].toUpperCase(),
                style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                Text(
                  widget.isOnline ? '在线' : '离线',
                  style: const TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (_, i) => _buildMessageBubble(messages[i]),
            ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: _surfaceColor,
              border: Border(top: BorderSide(color: _borderColor, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file,
                      color: _textSecondary, size: 22),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (v) => ref
                        .read(_hasTextProvider.notifier)
                        .state = v.trim().isNotEmpty,
                    textInputAction: TextInputAction.newline,
                    maxLines: 5,
                    minLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      hintStyle: const TextStyle(
                          color: _textSecondary, fontSize: 15),
                      filled: true,
                      fillColor: _bgColor,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Send / Voice toggle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasText ? _primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      hasText ? Icons.send : Icons.mic,
                      color: hasText ? Colors.white : _textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      if (hasText) {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          ref.read(_messagesProvider.notifier).state = [
                            ...ref.read(_messagesProvider),
                            _ChatMessage(
                                content: text, isMine: true, time: '刚刚'),
                          ];
                          controller.clear();
                          ref.read(_hasTextProvider.notifier).state = false;
                        }
                      }
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isMine = msg.isMine;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: _primaryColor.withValues(alpha: 0.2),
              child: Text(
                widget.peerName[0].toUpperCase(),
                style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: _buildBubbleContent(msg, isMine),
          ),
          if (isMine) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(_ChatMessage msg, bool isMine) {
    final color = isMine ? _bubbleMine : _bubbleOther;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMine ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight:
          isMine ? const Radius.circular(4) : const Radius.circular(16),
    );

    Widget content;
    switch (msg.type) {
      case _MsgType.image:
        content = _buildImagePlaceholder();
        break;
      case _MsgType.cashu:
        content = _buildCashuCard();
        break;
      case _MsgType.text:
        content = Text(msg.content,
            style: const TextStyle(color: Colors.white, fontSize: 15));
        break;
    }

    return Column(
      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints:
              const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: color, borderRadius: radius),
          child: content,
        ),
        const SizedBox(height: 2),
        Text(msg.time,
            style: const TextStyle(color: _textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, color: _textSecondary, size: 32),
            SizedBox(height: 4),
            Text('图片', style: TextStyle(color: _textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCashuCard() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7931A), Color(0xFFE67E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.token, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              const Text('Cashu',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Text('⚡',
                  style: TextStyle(
                      fontSize: 16, color: Colors.white.withValues(alpha: 0.7))),
            ],
          ),
          const SizedBox(height: 10),
          const Text('21 sats',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Tap to claim',
              style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

enum _MsgType { text, image, cashu }

class _ChatMessage {
  final String content;
  final bool isMine;
  final String time;
  final _MsgType type;

  const _ChatMessage({
    required this.content,
    required this.isMine,
    required this.time,
    this.type = _MsgType.text,
  });
}

const _sampleMessages = <_ChatMessage>[
  _ChatMessage(content: '嘿，最近怎么样？', isMine: false, time: '14:20'),
  _ChatMessage(content: '不错！正在弄那个Flutter项目', isMine: true, time: '14:21'),
  _ChatMessage(content: '酷，听说你搞了Cashu集成？', isMine: false, time: '14:22'),
  _ChatMessage(content: '对，给你看个效果', isMine: true, time: '14:22'),
  _ChatMessage(content: '', isMine: true, time: '14:23', type: _MsgType.cashu),
  _ChatMessage(content: '', isMine: false, time: '14:24', type: _MsgType.image),
  _ChatMessage(content: '厉害了！👍', isMine: false, time: '14:25'),
];
