import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, 
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Basic error handling wrapper
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      // Handle Dio specific errors here
      return Exception(error.message);
    }
    return Exception(error.toString());
  }
}
