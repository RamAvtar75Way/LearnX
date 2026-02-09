import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';
import '../utils/extensions.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateChanges => _authStateController.stream;

  AuthService();

  // Initialize
  Future<void> initialize() async {
    try {
      // Check current session
      String? sessionData = await _storage.read(key: 'current_session_user');
      if (sessionData != null) {
        _userModel = UserModel.fromMap(jsonDecode(sessionData));
        _authStateController.add(true);
      } else {
        _authStateController.add(false);
      }
      notifyListeners();
    } catch (e) {
      print("Error initializing auth: $e");
      _authStateController.add(false);
    }
  }

  // Helper to get all users DB
  Future<Map<String, dynamic>> _getUsersDb() async {
    String? jsonStr = await _storage.read(key: 'local_users_db');
    if (jsonStr == null) return {};
    return Map<String, dynamic>.from(jsonDecode(jsonStr));
  }

  // Helper to save users DB
  Future<void> _saveUsersDb(Map<String, dynamic> db) async {
    await _storage.write(key: 'local_users_db', value: jsonEncode(db));
  }

  // Sign In
  Future<String?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate net
    
    try {
      final db = await _getUsersDb();
      final userRecord = db[email]; // Look up by email

      if (userRecord != null) {
        // User found, check password
        if (userRecord['password'] == password) {
           // Success! Create Session
           final userJson = userRecord['userData'];
           await _storage.write(key: 'current_session_user', value: jsonEncode(userJson));
           
           _userModel = UserModel.fromMap(userJson);
           _authStateController.add(true);
           notifyListeners();
           return null;
        } else {
          return "Invalid password";
        }
      }

      // If user not found, strict error (they must register)
      return "User not found. Please register.";
      
    } catch (e) {
      return "Login failed: $e";
    }
  }

  // Register
  Future<String?> registerWithEmail(String email, String password, String name, String role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final db = await _getUsersDb();
      
      if (db.containsKey(email)) {
        return "Email already registered. Please login.";
      }

      final newUser = UserModel(
        uid: const Uuid().v4(), 
        email: email, 
        name: name, 
        role: role
      );
      
      // Save to DB
      db[email] = {
        'password': password,
        'userData': newUser.toMap(),
      };
      await _saveUsersDb(db);
      
      // Auto-Login (Create Session)
      await _storage.write(key: 'current_session_user', value: jsonEncode(newUser.toMap()));
      
      _userModel = newUser;
      _authStateController.add(true);
      notifyListeners();
      return null;
    } catch (e) {
      return "Registration failed: $e";
    }
  }

  // Update Profile
  Future<String?> updateUserProfile({String? name, String? profileImage}) async {
    try {
      if (_userModel == null) return "No user logged in";

      final updatedUser = _userModel!.copyWith(
        name: name ?? _userModel!.name,
        profileImage: profileImage ?? _userModel!.profileImage,
      );

      // Update in DB
      final db = await _getUsersDb();
      if (db.containsKey(_userModel!.email)) {
        db[_userModel!.email]['userData'] = updatedUser.toMap();
        await _saveUsersDb(db);
        
        // Update Session
        await _storage.write(key: 'current_session_user', value: jsonEncode(updatedUser.toMap()));
        
        _userModel = updatedUser;
        notifyListeners();
        return null;
      }
      return "User record not found";
    } catch (e) {
      return "Update failed: $e";
    }
  }

  // Payment Methods
  Future<List<String>> getPaymentMethods() async {
    final db = await _getUsersDb();
    if (_userModel != null && db.containsKey(_userModel!.email)) {
       final userData = db[_userModel!.email];
       if (userData.containsKey('paymentMethods')) {
         return List<String>.from(userData['paymentMethods']);
       }
    }
    return ["Visa ending in 1234"]; // Default mock
  }

  Future<void> addPaymentMethod(String method) async {
    if (_userModel == null) return;
    final db = await _getUsersDb();
    if (db.containsKey(_userModel!.email)) {
       var methods = db[_userModel!.email]['paymentMethods'] ?? [];
       methods = List<String>.from(methods);
       methods.add(method);
       db[_userModel!.email]['paymentMethods'] = methods;
       await _saveUsersDb(db);
       notifyListeners();
    }
  }

  Future<void> removePaymentMethod(String method) async {
    if (_userModel == null) return;
    final db = await _getUsersDb();
    if (db.containsKey(_userModel!.email)) {
       var methods = db[_userModel!.email]['paymentMethods'] ?? [];
       methods = List<String>.from(methods);
       methods.remove(method);
       db[_userModel!.email]['paymentMethods'] = methods;
       await _saveUsersDb(db);
       notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _storage.delete(key: 'current_session_user'); // Clear only session
    _userModel = null;
    _authStateController.add(false);
    notifyListeners();
  }

  Future<UserModel?> getUserById(String uid) async {
    final db = await _getUsersDb();
    for (var key in db.keys) {
      final data = db[key]['userData'];
      if (data['uid'] == uid) {
        return UserModel.fromMap(data);
      }
    }
    return null;
  }
}

