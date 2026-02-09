import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../services/storage_service.dart';
import '../constants/storage_keys.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await getIt<StorageService>().getAuthToken();
    if (token != null) {
      _isAuthenticated = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API
    await Future.delayed(const Duration(seconds: 1));
    await getIt<StorageService>().setAuthToken("mock_token");
    
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await getIt<StorageService>().removeSecure(StorageKeys.authToken); // matching key in storage_service
    _isAuthenticated = false;
    notifyListeners();
  }
}
