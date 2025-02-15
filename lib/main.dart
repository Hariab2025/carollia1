import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'views/login_page.dart';
import 'views/product_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Odoo Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Obx(() => Get.find<AuthController>().isLoggedIn.value
          ? ProductListPage()
          : LoginPage()),
    );
  }
}