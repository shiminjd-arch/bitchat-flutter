import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/community_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fadeTransition(
        context, state, const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/chats',
      pageBuilder: (context, state) => _fadeTransition(
        context, state, const ChatListScreen(),
      ),
    ),
    GoRoute(
      path: '/chat/:peerId',
      pageBuilder: (context, state) {
        final peerId = state.pathParameters['peerId']!;
        return _fadeTransition(
          context, state, ChatScreen(peerId: peerId, peerName: peerId),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _fadeTransition(
        context, state, const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/ai',
      pageBuilder: (context, state) => _fadeTransition(
        context, state, const AiChatScreen(),
      ),
    ),
    GoRoute(
      path: '/community',
      pageBuilder: (context, state) => _fadeTransition(
        context, state, const CommunityScreen(),
      ),
    ),
  ],
);

CustomTransitionPage<void> _fadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

class BitchatApp extends StatelessWidget {
  const BitchatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '匿匿',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
