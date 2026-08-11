import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

const _bgColor = Color(0xFF0D1117);
const _surfaceColor = Color(0xFF161B22);
const _primaryColor = Color(0xFF4A90D9);
const _borderColor = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);

final _apiKeyProvider = StateProvider<String>((ref) => '');
final _apiKeyExpandedProvider = StateProvider<bool>((ref) => false);
final _messagesProvider =
    StateProvider<List<_AiMessage>>((ref) => []);
final _isLoadingProvider = StateProvider<bool>((ref) => false);
final _inputControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) => TextEditingController());

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(_apiKeyProvider);
    final isExpanded = ref.watch(_apiKeyExpandedProvider);
    final messages = ref.watch(_messagesProvider);
    final isLoading = ref.watch(_isLoadingProvider);
    final controller = ref.watch(_inputControllerProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('AI 助手',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Collapsible API Key bar
          _buildApiKeyBar(apiKey, isExpanded, ref),

          // Messages
          Expanded(
            child: messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount:
                        messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (isLoading && i == messages.length) {
                        return _buildLoadingBubble();
                      }
                      return _buildBubble(messages[i]);
                    },
                  ),
          ),

          // Input
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: bottomInset + 8,
            ),
            decoration: const BoxDecoration(
              color: _surfaceColor,
              border:
                  Border(top: BorderSide(color: _borderColor, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(controller, apiKey, ref),
                    style:
                        const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '向 AI 提问...',
                      hintStyle: const TextStyle(
                          color: _textSecondary, fontSize: 15),
                      filled: true,
                      fillColor: _bgColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: isLoading
                        ? null
                        : () => _sendMessage(controller, apiKey, ref),
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

  Widget _buildApiKeyBar(String apiKey, bool isExpanded, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: const Border(
            bottom: BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                ref.read(_apiKeyExpandedProvider.notifier).state = !isExpanded,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.vpn_key_outlined,
                      color: _primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    apiKey.isEmpty ? '点击配置 DeepSeek API Key' : 'DeepSeek API Key',
                    style: TextStyle(
                      color:
                          apiKey.isEmpty ? _textSecondary : _primaryColor,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: _textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: (v) =>
                    ref.read(_apiKeyProvider.notifier).state = v,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  hintStyle: const TextStyle(
                      color: _textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: _bgColor,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primaryColor),
                  ),
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: _primaryColor, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('AI 助手',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('基于 DeepSeek 的智能对话',
              style: TextStyle(color: _textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBubble(_AiMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: _primaryColor, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF1A3A5C)
                    : const Color(0xFF21262D),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(msg.content,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: _primaryColor, size: 16),
          ),
          const SizedBox(width: 8),
          Shimmer.fromColors(
            baseColor: const Color(0xFF21262D),
            highlightColor: const Color(0xFF30363D),
            child: Container(
              width: 120,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                  bottomLeft: const Radius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(
    TextEditingController controller,
    String apiKey,
    WidgetRef ref,
  ) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('请先配置 DeepSeek API Key'),
            backgroundColor: Color(0xFFF85149)),
      );
      return;
    }

    controller.clear();

    ref.read(_messagesProvider.notifier).state = [
      ...ref.read(_messagesProvider),
      _AiMessage(content: text, isUser: true),
    ];

    ref.read(_isLoadingProvider.notifier).state = true;

    try {
      final response = await _dio.post(
        'https://api.deepseek.com/v1/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer $trimmedKey',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': text},
          ],
          'stream': false,
        },
      );

      final reply = response.data['choices']?[0]?['message']?['content'] ??
          '抱歉，没有收到回复。';

      ref.read(_messagesProvider.notifier).state = [
        ...ref.read(_messagesProvider),
        _AiMessage(content: reply.toString(), isUser: false),
      ];
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?['message']?.toString() ??
          '网络请求失败，请检查网络或API Key。';
      ref.read(_messagesProvider.notifier).state = [
        ...ref.read(_messagesProvider),
        _AiMessage(content: '错误: $errorMsg', isUser: false),
      ];
    } catch (e) {
      ref.read(_messagesProvider.notifier).state = [
        ...ref.read(_messagesProvider),
        _AiMessage(content: '发生未知错误: $e', isUser: false),
      ];
    } finally {
      ref.read(_isLoadingProvider.notifier).state = false;
    }
  }
}

class _AiMessage {
  final String content;
  final bool isUser;

  const _AiMessage({required this.content, required this.isUser});
}
