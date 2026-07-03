import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;
  bool _useFirebase = false;

  // Stream controller for mock authentication changes
  final StreamController<UserModel?> _mockAuthStreamController = StreamController<UserModel?>.broadcast();
  UserModel? _currentMockUser;

  AuthService()
      : _firebaseAuth = _isFirebaseInitialized() ? FirebaseAuth.instance : null,
        _firestore = _isFirebaseInitialized() ? FirebaseFirestore.instance : null {
    _useFirebase = _firebaseAuth != null;
    if (!_useFirebase) {
      _loadMockUser();
    }
  }

  static bool _isFirebaseInitialized() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool get isFirebaseEnabled => _useFirebase;

  // Load user from local storage (mock mode)
  Future<void> _loadMockUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.prefsUserKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentMockUser = UserModel.fromMap(userData, userData['id']);
        _mockAuthStreamController.add(_currentMockUser);
      } else {
        _mockAuthStreamController.add(null);
      }
    } catch (_) {
      _mockAuthStreamController.add(null);
    }
  }

  // Stream of User Auth State Changes
  Stream<UserModel?> get onAuthStateChanged {
    if (_useFirebase) {
      return _firebaseAuth!.authStateChanges().asyncMap((User? firebaseUser) async {
        if (firebaseUser == null) return null;
        try {
          final doc = await _firestore!.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists && doc.data() != null) {
            return UserModel.fromMap(doc.data()!, firebaseUser.uid);
          }
          return UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
            isAdmin: false,
          );
        } catch (_) {
          return UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.email?.split('@').first ?? 'User',
            isAdmin: false,
          );
        }
      });
    } else {
      return _mockAuthStreamController.stream;
    }
  }

  // Sign In
  Future<UserModel> signIn(String email, String password) async {
    if (_useFirebase) {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = credential.user!.uid;
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      final user = UserModel(id: uid, email: credential.user!.email ?? email, name: email.split('@').first);
      await _firestore!.collection('users').doc(uid).set(user.toMap());
      return user;
    } else {
      // Mock Sign In logic
      // Check if email contains 'admin' -> grant admin role
      final isAdmin = email.toLowerCase().contains('admin');
      final mockUser = UserModel(
        id: 'mock_uid_${email.hashCode}',
        email: email,
        name: email.split('@').first,
        isAdmin: isAdmin,
      );
      _currentMockUser = mockUser;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefsUserKey, jsonEncode({
        'id': mockUser.id,
        'email': mockUser.email,
        'name': mockUser.name,
        'isAdmin': mockUser.isAdmin,
      }));
      
      _mockAuthStreamController.add(_currentMockUser);
      return mockUser;
    }
  }

  // Sign Up
  Future<UserModel> signUp(String email, String name, String password) async {
    if (_useFirebase) {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = credential.user!.uid;
      final user = UserModel(id: uid, email: email, name: name, isAdmin: email.toLowerCase().contains('admin'));
      await _firestore!.collection('users').doc(uid).set(user.toMap());
      return user;
    } else {
      final isAdmin = email.toLowerCase().contains('admin');
      final mockUser = UserModel(
        id: 'mock_uid_${email.hashCode}',
        email: email,
        name: name,
        isAdmin: isAdmin,
      );
      _currentMockUser = mockUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefsUserKey, jsonEncode({
        'id': mockUser.id,
        'email': mockUser.email,
        'name': mockUser.name,
        'isAdmin': mockUser.isAdmin,
      }));

      _mockAuthStreamController.add(_currentMockUser);
      return mockUser;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    if (_useFirebase) {
      await _firebaseAuth!.signOut();
    } else {
      _currentMockUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefsUserKey);
      _mockAuthStreamController.add(null);
    }
  }
}
