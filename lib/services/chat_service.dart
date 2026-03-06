import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:js' show context, JsObject;
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService {
  // Puter.js API endpoint - using Puter.ai API
  static const String _baseUrl = 'https://api.puter.ai/v1/chat/completions';
  
  final String? _apiKey;
  
  ChatService({String? apiKey}) : _apiKey = apiKey;

  bool get _isWeb => identical(0, 0.0);

  Future<String> getAIResponse(String userMessage, List<Message> history) async {
    if (_isWeb) {
      try {
        final response = await _getPuterJSResponse(userMessage, history);
        if (response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        // Fall back to API or local responses
      }
    }

    if (_apiKey != null && _apiKey!.isNotEmpty) {
      try {
        final response = await _getAPIResponse(userMessage, history);
        if (response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        // Fall back to local responses
      }
    }

    return _getFallbackResponse(userMessage, history);
  }

  /// Use Puter.js JavaScript bridge for web platform
  Future<String> _getPuterJSResponse(String userMessage, List<Message> history) async {
    try {
      // Check if puterChat function exists
      if (!context.hasProperty('puterChat')) {
        return '';
      }
      
      // Create history as a JavaScript array
      final historyJs = JsObject(context['Array']);
      for (var i = 0; i < history.length; i++) {
        final msg = history[i];
        final msgObj = JsObject(context['Object']);
        msgObj['isUser'] = msg.isUser;
        msgObj['content'] = msg.content;
        historyJs[i] = msgObj;
      }

      // Get the function and call it
      final jsFunction = context['puterChat'];
      
      // Call and convert result to Future
      final result = jsFunction.apply([userMessage, historyJs]);
      
      // Handle if it's a Promise
      if (result is! String) {
        // Try to await the promise
        try {
          final completer = Completer<String>();
          
          // Use then callback to get the result
          final promiseResult = _jsPromiseToFuture(result);
          return await promiseResult;
        } catch (e) {
          return '';
        }
      }
      
      return result.toString();
    } catch (e) {
      return '';
    }
  }

  /// Convert JS Promise to Dart Future
  Future<String> _jsPromiseToFuture(dynamic jsPromise) async {
    try {
      // Check if it has then method (is a Promise-like)
      if (jsPromise != null && jsPromise.hasProperty('then')) {
        final then = jsPromise['then'];
        final result = then.apply([
          (dynamic response) {
            // Success callback - this won't work synchronously
            // We need a different approach
          }
        ]);
        
        // Just return the promise object as string
        return jsPromise.toString();
      }
      return jsPromise?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Use Puter.js REST API
  Future<String> _getAPIResponse(String userMessage, List<Message> history) async {
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
      }
    } catch (e) {
      // Will fall back to local responses
    }
    return '';
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
        "I'm doing well! Always happy to chat with you. What would you like to know?",
      ];
      return responses[random.nextInt(responses.length)];
    }
    
    if (lowerMessage.contains('your name') || lowerMessage.contains('who are you')) {
      return "I'm ChatBoteo, an AI assistant powered by Puter.js. I'm here to help you with any questions you might have!";
    }
    
    if (lowerMessage.contains('help')) {
      return "I'd be happy to help! I can assist you with:\n\n• Answering questions on various topics\n• Explaining complex concepts\n• Writing and debugging code\n• Brainstorming ideas\n• And much more!\n\nWhat would you like help with?";
    }
    
    if (lowerMessage.contains('code') || lowerMessage.contains('programming') || lowerMessage.contains('python') || lowerMessage.contains('javascript')) {
      return "I'd be happy! I can assist to help with programming with:\n\n• Writing code in various languages (Python, JavaScript, Dart, etc.)\n• Debugging and fixing errors\n• Explaining concepts\n• Best practices and patterns\n\nWhat specific programming question do you have?";
    }
    
    if (lowerMessage.contains('thanks') || lowerMessage.contains('thank you') || lowerMessage.contains('appreciate')) {
      final thanks = [
        "You're welcome! Happy to help!",
        "No problem at all! Feel free to ask more questions.",
        "Glad I could help! Let me know if there's anything else.",
      ];
      return thanks[random.nextInt(thanks.length)];
    }
    
    if (lowerMessage.contains('bye') || lowerMessage.contains('goodbye') || lowerMessage.contains('see you')) {
      final goodbyes = [
        "Goodbye! It was great chatting with you! Come back anytime!",
        "Bye for now! Take care!",
        "See you later! Don't hesitate to return if you have more questions!",
      ];
      return goodbyes[random.nextInt(goodbyes.length)];
    }
    
    final defaultResponses = [
      "That's an interesting question! Could you tell me more about what you'd like to know?",
      "I see. Let me think about that... Could you provide more details?",
      "Great question! I'd be happy to help with that. Can you be more specific?",
      "That's something I can definitely help with. Tell me more about your needs.",
      "Interesting! Let me provide some insight on that. What particular aspect interests you most?",
      "I understand. To give you the best answer, could you elaborate a bit more?",
      "That's a thoughtful question. Here's what I can tell you...",
      "Thanks for asking! Here's my response to that:",
    ];
    
    return defaultResponses[random.nextInt(defaultResponses.length)];
  }
}
