import 'package:carollia/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class ProductController extends GetxController {
  final ApiService _apiService = ApiService();
  var products = <Product>[].obs;
  var isLoading = false.obs;

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final products = await _apiService.getProducts(
        authController.db ?? '',
        authController.userId ?? 0,
      );
      this.products.value = products;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}