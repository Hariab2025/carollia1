import 'dart:convert';
import 'dart:typed_data';
import 'package:carollia/views/login_page.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../controllers/auth_controller.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://your-odoo-server.com',
    connectTimeout: Duration(milliseconds: 5000),
    receiveTimeout: Duration(milliseconds: 3000),
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final authController = Get.find<AuthController>();
        if (authController.sessionId != null) {
          options.headers['Cookie'] = 'session_id=${authController.sessionId}';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          Get.find<AuthController>().logout();
          Get.offAll(() => LoginPage());
          Get.snackbar('Session Expired', 'Please login again');
        }
        return handler.next(error);
      },
    ));
    _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Map<String, dynamic>?> authenticate(
      String db, String username, String password) async {
    try {
      final response = await _dio.post('/jsonrpc', data: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "service": "common",
          "method": "authenticate",
          "args": [db, username, password, {}]
        },
        "id": 1
      });

      if (response.data['result'] == null) return null;

      final sessionId = _parseSessionId(response.headers['set-cookie']);
      final userId = response.data['result'];
      return {'session_id': sessionId, 'user_id': userId};
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> getProducts(String db, int userId) async {
    try {
      final response = await _dio.post('/jsonrpc', data: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "service": "object",
          "method": "execute_kw",
          "args": [
            db,
            userId,
            "",
            "product.template",
            "search_read",
            [],
            {"fields": ["name", "list_price", "image_1920"]}
          ]
        },
        "id": 1
      });

      return (response.data['result'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  String? _parseSessionId(List<String>? cookies) {
    if (cookies == null) return null;
    for (var cookie in cookies) {
      if (cookie.startsWith('session_id=')) {
        return cookie.split(';').first.split('=').last;
      }
    }
    return null;
  }

  String _handleError(DioError error) {
    if (error.type == DioErrorType.connectionTimeout ||
        error.type == DioErrorType.receiveTimeout ||
        error.type == DioErrorType.sendTimeout) {
      return 'Connection timeout';
    } else if (error.type == DioErrorType.connectionError) {
      return 'No internet connection';
    } else if (error.response?.statusCode == 401) {
      return 'Authentication failed';
    }
    return 'Unknown error occurred';
  }
}

class Product {
  final String name;
  final double price;
  // final Uint8List? image;

  Product({required this.name, required this.price, image});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['list_price']?.toDouble() ?? 0.0,
      image: json['image_1920'] != null 
          ? base64Decode(json['image_1920'].split(',').last)
          : null,
    );
  }
}