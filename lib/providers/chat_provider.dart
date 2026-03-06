import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  static const String _conversationsKey = 'conversations';
  
  final ChatService _chatService = ChatService();
  
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  bool _isTyping = false;

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  Future<void> init() async {
    await _loadConversations();
    if (_conversations.isNotEmpty) {
      _currentConversation = _conversations.first;
    }
    notifyListeners();
  }

  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getString(_conversationsKey);
    
    if (conversationsJson != null) {
      final List<dynamic> decoded = json.decode(conversationsJson);
      _conversations = decoded.map((c) => Conversation.fromJson(c)).toList();
      _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = json.encode(
      _conversations.map((c) => c.toJson()).toList(),
    );
    await prefs.setString(_conversationsKey, conversationsJson);
  }

  void startNewConversation() {
    final now = DateTime.now();
    _currentConversation = Conversation(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
    _conversations.insert(0, _currentConversation!);
    notifyListeners();
  }

  Future<void> selectConversation(Conversation conversation) async {
    _currentConversation = conversation;
    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((c) => c.id == conversationId);
    await _saveConversations();
    
    if (_currentConversation?.id == conversationId) {
      if (_conversations.isNotEmpty) {
        _currentConversation = _conversations.first;
      } else {
        startNewConversation();
      }
    }
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_currentConversation == null) {
      startNewConversation();
    }

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [..._currentConversation!.messages, userMessage];
    
    // Update title if it's the first message
    String title = _currentConversation!.title;
    if (updatedMessages.length == 1) {
      title = content.length > 30 ? '${content.substring(0, 30)}...' : content;
    }

    _currentConversation = _currentConversation!.copyWith(
      messages: updatedMessages,
      title: title,
      updatedAt: DateTime.now(),
    );

    // Update in conversations list
    final index = _conversations.indexWhere((c) => c.id == _currentConversation!.id);
    if (index != -1) {
      _conversations[index] = _currentConversation!;
    }

    _isTyping = true;
    notifyListeners();

    try {
      final response = await _chatService.getAIResponse(
        content,
        _currentConversation!.messages.where((m) => m.isUser).toList(),
      );

      final botMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final finalMessages = [..._currentConversation!.messages, botMessage];
      _currentConversation = _currentConversation!.copyWith(
        messages: finalMessages,
        updatedAt: DateTime.now(),
      );

      if (index != -1) {
        _conversations[index] = _currentConversation!;
        // Re-sort by updated time
        _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }

      await _saveConversations();
    } catch (e) {
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      final finalMessages = [..._currentConversation!.messages, errorMessage];
      _currentConversation = _currentConversation!.copyWith(
        messages: finalMessages,
      );

      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }
    }

    _isTyping = false;
    notifyListeners();
  }
}
