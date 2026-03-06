import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _emailKey = 'user_email';
  static const String _usernameKey = 'user_username';
  
  bool _isLoggedIn = false;
  String _email = '';
  String _username = '';
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  String get email => _email;
  String get username => _username;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    _email = prefs.getString(_emailKey) ?? '';
    _username = prefs.getString(_usernameKey) ?? 'User';
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Simulate login - in production, you'd call your API here
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_emailKey, email);
      await prefs.setString(_usernameKey, email.split('@').first);
      
      _isLoggedIn = true;
      _email = email;
      _username = email.split('@').first;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String email, String password, String username) async {
    // Simulate signup - in production, you'd call your API here
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_emailKey, email);
      await prefs.setString(_usernameKey, username);
      
      _isLoggedIn = true;
      _email = email;
      _username = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    
    _isLoggedIn = false;
    notifyListeners();
  }
}
