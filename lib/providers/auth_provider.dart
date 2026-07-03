import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _isLoading = true;
    _authService.onAuthStateChanged.listen((UserModel? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFirebase => _authService.isFirebaseEnabled;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst(RegExp(r'\[.*\]\s*'), '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String name, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.signUp(email, name, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst(RegExp(r'\[.*\]\s*'), '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
}
