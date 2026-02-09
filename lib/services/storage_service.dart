import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService(this._prefs, this._secureStorage);

  // --- Shared Preferences ---

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // --- Secure Storage ---

  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  // --- Helpers ---

  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  // Specific helper for Auth Token
  Future<void> setAuthToken(String token) async {
    await setSecureString(StorageKeys.authToken, token);
  }

  Future<String?> getAuthToken() async {
    return await getSecureString(StorageKeys.authToken);
  }
}
