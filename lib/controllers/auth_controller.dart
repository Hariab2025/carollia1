
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../api/api_service.dart';

class AuthController extends GetxController {
  final storage = FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  
  var isLoggedIn = false.obs;
  String? sessionId;
  String? db;
  int? userId;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    sessionId = await storage.read(key: 'session_id');
    db = await storage.read(key: 'db');
    userId = int.tryParse(await storage.read(key: 'user_id') ?? '');
    
    if (sessionId != null && userId != null) {
      isLoggedIn.value = true;
    }
  }

  Future<void> login(String db, String username, String password) async {
    try {
      final result = await _apiService.authenticate(db, username, password);
      if (result != null) {
        sessionId = result['session_id'];
        userId = result['user_id'];
        this.db = db;
        
        await storage.write(key: 'session_id', value: sessionId);
        await storage.write(key: 'user_id', value: userId.toString());
        await storage.write(key: 'db', value: db);
        
        isLoggedIn.value = true;
      }
    } catch (e) {
      logout();
      Get.snackbar('Login Failed', e.toString());
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
    sessionId = null;
    userId = null;
    db = null;
    isLoggedIn.value = false;
  }
}