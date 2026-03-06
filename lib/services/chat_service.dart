import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService {
  // Puter.js API endpoint - using a free AI API
  // Note: In production, you would use your own Puter.js API key
  static const String _baseUrl = 'https://api.puter.ai/v1/chat/completions';
  
  // For demo purposes, we'll also include a fallback local response system
  // since we may not have an API key
  final String? _apiKey;
  
  ChatService({String? apiKey}) : _apiKey = apiKey;

  Future<String> getAIResponse(String userMessage, List<Message> history) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      // Use fallback responses for demo
      return _getFallbackResponse(userMessage, history);
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': _getSystemPrompt()},
            ...history.map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            }),
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return _getFallbackResponse(userMessage, history);
      }
    } catch (e) {
      return _getFallbackResponse(userMessage, history);
    }
  }

  String _getSystemPrompt() {
    return '''You are ChatBoteo, a helpful and friendly AI assistant created by Puter.js. 
You are knowledgeable in many topics including programming, science, history, mathematics, and general knowledge.
You provide clear, concise, and accurate responses.
You are always polite and respectful.
Your responses are friendly and conversational.''';
  }

  String _getFallbackResponse(String message, List<Message> history) {
    final lowerMessage = message.toLowerCase();
    final random = Random();
    
    // Check for specific keywords and provide contextual responses
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      final greetings = [
        "Hello! How can I help you today?",
        "Hi there! What would you like to talk about?",
        "Hey! I'm here to help. What's on your mind?",
        "Greetings! How may I assist you today?",
      ];
      return greetings[random.nextInt(greetings.length)];
    }
    
    if (lowerMessage.contains('how are you')) {
      final responses = [
        "I'm doing great, thank you for asking! I'm here and ready to help you.",
        "I'm fantastic! Thanks for checking in. How can I assist you today?",
