import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'navigation_service.dart';
import 'storage_service.dart';
import 'auth_interceptor.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  print("setupLocator: Starting registration...");
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  // Services
  getIt.registerLazySingleton<Navigation>(() => Navigation());
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<SharedPreferences>(), getIt<FlutterSecureStorage>())
  );
  
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(getIt<StorageService>())
  );

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.interceptors.add(getIt<AuthInterceptor>());
    return dio;
  });

  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));
}
