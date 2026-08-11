import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _bgColor = Color(0xFF0D1117);
const _surfaceColor = Color(0xFF161B22);
const _primaryColor = Color(0xFF4A90D9);
const _borderColor = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);
const _errorColor = Color(0xFFF85149);
const _onlineGreen = Color(0xFF3FB950);

final _codeValuesProvider =
    StateProvider<List<String>>((ref) => List.filled(6, ''));
final _focusNodesProvider = Provider<List<FocusNode>>(
    (ref) => List.generate(6, (_) => FocusNode()));
final _shakeProvider = StateProvider<bool>((ref) => false);
final _fadeInProvider = StateProvider<bool>((ref) => false);

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final codeValues = ref.watch(_codeValuesProvider);
    final focusNodes = ref.watch(_focusNodesProvider);
    final shake = ref.watch(_shakeProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('加入社区',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.group_add_outlined,
                        color: _primaryColor, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text('输入邀请码加入社区',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('输入6位邀请码以加入一个加密社区频道',
                      style: TextStyle(color: _textSecondary, fontSize: 14),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Code Input Boxes
            FadeTransition(
              opacity: _fadeAnimation,
              child: _shakeWrapper(
                shake: shake,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 8),
                      child: SizedBox(
                        width: 48,
                        height: 56,
                        child: TextField(
                          focusNode: focusNodes[i],
                          onChanged: (v) {
                            if (v.length > 1) {
                              final last = v[v.length - 1];
                              final newValues =
                                  List<String>.from(codeValues);
                              newValues[i] = last;
                              ref
                                  .read(_codeValuesProvider.notifier)
                                  .state = newValues;
                              if (i < 5) {
                                focusNodes[i + 1].requestFocus();
                              }
                            } else {
                              final newValues =
                                  List<String>.from(codeValues);
                              newValues[i] = v;
                              ref
                                  .read(_codeValuesProvider.notifier)
                                  .state = newValues;
                              if (v.isEmpty && i > 0) {
                                focusNodes[i - 1].requestFocus();
                              }
                            }
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: i == 5
                              ? TextInputAction.done
                              : TextInputAction.next,
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: _surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: codeValues[i].isNotEmpty
                                    ? _primaryColor
                                    : _borderColor,
                                width: codeValues[i].isNotEmpty ? 2 : 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: codeValues[i].isNotEmpty
                                    ? _primaryColor
                                    : _borderColor,
                                width: codeValues[i].isNotEmpty ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: _primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Join Button
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _joinCommunity(codeValues),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('加入社区',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Preview Cards
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text('热门社区',
                        style: TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  _CommunityCard(
                    name: 'Bitcoin 爱好者',
                    members: 1283,
                    type: CommunityType.channel,
                    description: '讨论比特币与闪电网络技术',
                  ),
                  const SizedBox(height: 10),
                  _CommunityCard(
                    name: 'Nostr 开发者',
                    members: 567,
                    type: CommunityType.group,
                    description: 'Nostr 协议开发与生态讨论',
                  ),
                  const SizedBox(height: 10),
                  _CommunityCard(
                    name: '隐私技术研究',
                    members: 342,
                    type: CommunityType.channel,
                    description: '匿名通讯与密码学技术交流',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shakeWrapper({required bool shake, required Widget child}) {
    if (!shake) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (_, t, c) {
        return Transform.translate(
          offset: Offset(8 * (1 - t) * math.sin(t * 10), 0),
          child: c,
        );
      },
      child: child,
    );
  }

  void _joinCommunity(List<String> codeValues) {
    final code = codeValues.join();
    if (code.length < 6) {
      ref.read(_shakeProvider.notifier).state = true;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) ref.read(_shakeProvider.notifier).state = false;
      });
      return;
    }
    // TODO: 接入加入社区逻辑
  }
}

enum CommunityType { channel, group }

class _CommunityCard extends StatelessWidget {
  final String name;
  final int members;
  final CommunityType type;
  final String description;

  const _CommunityCard({
    required this.name,
    required this.members,
    required this.type,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: type == CommunityType.channel
                    ? _primaryColor.withValues(alpha: 0.15)
                    : const Color(0xFFF0883E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type == CommunityType.channel
                    ? Icons.tag
                    : Icons.group_outlined,
                color: type == CommunityType.channel
                    ? _primaryColor
                    : const Color(0xFFF0883E),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(description,
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '$members',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
                const SizedBox(height: 2),
                const Text('成员',
                    style: TextStyle(color: _textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
