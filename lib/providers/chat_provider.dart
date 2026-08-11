import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

enum ChatListStatus { initial, loading, loaded, error }

class ChatListState {
  final ChatListStatus status;
  final List<Chat> chats;
  final Map<String, String> typingUsers;
  final String? error;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chats = const [],
    this.typingUsers = const {},
    this.error,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<Chat>? chats,
    Map<String, String>? typingUsers,
    String? error,
    bool clearError = false,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      typingUsers: typingUsers ?? this.typingUsers,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatNotifier extends StateNotifier<ChatListState> {
  ChatNotifier() : super(const ChatListState());

  final _chatService = ChatService.instance;

  void loadChats() {
    state = state.copyWith(status: ChatListStatus.loading);
    try {
      _chatService.initMockData();
      state = ChatListState(
        status: ChatListStatus.loaded,
        chats: _chatService.chats,
      );
    } catch (e) {
      state = state.copyWith(status: ChatListStatus.error, error: e.toString());
    }
  }

  List<Message> getMessages(String peerId) {
    return _chatService.getMessages(peerId);
  }

  Future<void> sendMessage(String peerId, String content,
      {MessageType type = MessageType.text}) async {
    try {
      await _chatService.sendMessage(
        peerId: peerId,
        content: content,
        type: type,
      );
      state = state.copyWith(chats: _chatService.chats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearChat(String peerId) {
    _chatService.clearChat(peerId);
    state = state.copyWith(chats: _chatService.chats);
  }

  Chat? chatByPeerId(String peerId) {
    try {
      return _chatService.chats.where((c) => c.peerId == peerId).firstOrNull;
    } catch (_) {
      return null;
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatListState>((ref) {
  return ChatNotifier();
});

final messagesProvider =
    Provider.family<List<Message>, String>((ref, peerId) {
  final notifier = ref.watch(chatProvider.notifier);
  return notifier.getMessages(peerId);
});

final chatByPeerIdProvider = Provider.family<Chat?, String>((ref, peerId) {
  final notifier = ref.watch(chatProvider.notifier);
  return notifier.chatByPeerId(peerId);
});
