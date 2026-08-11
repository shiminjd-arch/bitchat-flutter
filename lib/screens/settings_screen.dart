import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _bgColor = Color(0xFF0D1117);
const _surfaceColor = Color(0xFF161B22);
const _primaryColor = Color(0xFF4A90D9);
const _borderColor = Color(0xFF30363D);
const _textSecondary = Color(0xFF8B949E);
const _onlineGreen = Color(0xFF3FB950);
const _errorColor = Color(0xFFF85149);

final _torEnabledProvider = StateProvider<bool>((ref) => false);
final _torConnectingProvider = StateProvider<bool>((ref) => false);
final _deepSeekKeyProvider = StateProvider<String>((ref) => '');
final _elevenLabsKeyProvider = StateProvider<String>((ref) => '');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torEnabled = ref.watch(_torEnabledProvider);
    final torConnecting = ref.watch(_torConnectingProvider);
    final deepSeekKey = ref.watch(_deepSeekKeyProvider);
    final elevenLabsKey = ref.watch(_elevenLabsKeyProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('设置',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Profile
          _sectionHeader('个人资料'),
          _card([
            _tile(
              icon: Icons.person_outline,
              iconBg: _primaryColor,
              title: '头像与昵称',
              subtitle: '用户 · 匿匿用户',
              trailing: const Icon(Icons.chevron_right,
                  color: _textSecondary, size: 20),
            ),
          ]),
          const SizedBox(height: 24),

          // Section 2: Privacy & Security
          _sectionHeader('隐私与安全'),
          _card([
            _torTile(ref, torEnabled, torConnecting),
            _tile(
              icon: Icons.lock_outline,
              iconBg: const Color(0xFFF0883E),
              title: '安全PIN',
              subtitle: '保护你的本地数据',
              trailing: const Icon(Icons.chevron_right,
                  color: _textSecondary, size: 20),
            ),
          ]),
          const SizedBox(height: 24),

          // Section 3: API Keys
          _sectionHeader('API Keys'),
          _card([
            _expandableApiKeyTile(
              icon: Icons.key,
              iconBg: const Color(0xFF10A37F),
              title: 'DeepSeek API Key',
              hint: 'sk-...',
              value: deepSeekKey,
              onChanged: (v) =>
                  ref.read(_deepSeekKeyProvider.notifier).state = v,
            ),
            const _Divider(),
            _expandableApiKeyTile(
              icon: Icons.key,
              iconBg: const Color(0xFF8B5CF6),
              title: 'ElevenLabs API Key',
              hint: '输入API Key...',
              value: elevenLabsKey,
              onChanged: (v) =>
                  ref.read(_elevenLabsKeyProvider.notifier).state = v,
            ),
          ]),
          const SizedBox(height: 24),

          // Section 4: About
          _sectionHeader('关于'),
          _card([
            _tile(
              icon: Icons.info_outline,
              iconBg: _textSecondary,
              title: '关于匿匿',
              subtitle: '隐私优先的去中心化通讯',
              trailing: const Icon(Icons.chevron_right,
                  color: _textSecondary, size: 20),
            ),
            const _Divider(),
            _tile(
              icon: Icons.info_outline,
              iconBg: _textSecondary,
              title: '版本',
              subtitle: 'v1.0.0',
              trailing: const SizedBox.shrink(),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          )),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _torTile(WidgetRef ref, bool enabled, bool connecting) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7D4698).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined,
                color: Color(0xFF7D4698), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Tor',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    _TorStatusPill(enabled: enabled, connecting: connecting),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('匿名化网络流量',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (v) {
              ref.read(_torEnabledProvider.notifier).state = v;
              if (v) {
                ref.read(_torConnectingProvider.notifier).state = true;
                Future.delayed(const Duration(seconds: 2), () {
                  ref.read(_torConnectingProvider.notifier).state = false;
                });
              }
            },
            activeColor: _primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _expandableApiKeyTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return _ApiKeyTile(
      icon: icon,
      iconBg: iconBg,
      title: title,
      hint: hint,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _TorStatusPill extends StatelessWidget {
  final bool enabled;
  final bool connecting;

  const _TorStatusPill({required this.enabled, required this.connecting});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    if (connecting) {
      color = const Color(0xFFF0883E);
      text = '连接中...';
    } else if (enabled) {
      color = _onlineGreen;
      text = '已连接';
    } else {
      color = _textSecondary;
      text = '未启用';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ApiKeyTile extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  const _ApiKeyTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ApiKeyTile> createState() => _ApiKeyTileState();
}

class _ApiKeyTileState extends State<_ApiKeyTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.iconBg.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.iconBg, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        widget.value.isNotEmpty ? '●●●●●●●●' : '未设置',
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right,
                      color: _textSecondary, size: 20),
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
              onChanged: widget.onChanged,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle:
                    const TextStyle(color: _textSecondary, fontSize: 13),
                filled: true,
                fillColor: _bgColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        color: _borderColor, height: 1, indent: 66, endIndent: 16);
  }
}
