
import 'dart:developer' as dev;

import '../../models/product_model.dart';
import '../../view_models/product_view_model.dart';

Product? getProductById(String productId, ProductViewModel productViewModel) {
    try {
      Product product =
          productViewModel.productList.firstWhere((p) => p.pId == productId);
      dev.log(
          "Retrieved product ID: $productId - Title: ${product.title}, Weight: ${product.weight}g, Purity: ${product.purity}");
      return product;
    } catch (e) {
      dev.log(
          "Failed to retrieve product ID: $productId - Error: ${e.toString()}");
      return null;
    }
  }