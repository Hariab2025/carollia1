import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';

class ProductListPage extends StatelessWidget {
  final ProductController _productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (_productController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: _productController.products.length,
          itemBuilder: (context, index) {
            final product = _productController.products[index];
            return ListTile(
              // leading: product.image != null
              //     ? Image.memory(product.image!, width: 50, height: 50)
              //     : Icon(Icons.image),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _productController.fetchProducts,
        child: Icon(Icons.refresh),
      ),
    );
  }
}