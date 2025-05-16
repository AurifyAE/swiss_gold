class CartModel {
  final bool success;
  final String message;
  final List<CartInfo> data;

  CartModel({required this.success, required this.message, required this.data});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      success: json['success'],
      message: json['message'],
      data: (json['info'] as List)
          .map((data) => CartInfo.fromJson(data))
          .toList(),
    );
  }
}

class CartInfo {
  final String id;
  final String userId;
  final List<CartItem> items;

  CartInfo({
    required this.id,
    required this.userId,
    required this.items,
  });

  factory CartInfo.fromJson(Map<String, dynamic> json) {
    return CartInfo(
      id: json['_id'],
      userId: json['userId'],
      items: (json['items'] as List).map((i) => CartItem.fromJson(i)).toList(),
    );
  }
}

class CartItem {
  final String productId;
  int quantity;
  final ProductDetails productDetails;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.productDetails,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'],
      productDetails: ProductDetails.fromJson(json['productDetails']),
    );
  }
}

class ProductDetails {
  final String title;
  final String description;
  final List<String> images;
  final num purity;
  final String sku;
  final String type;
  final num makingCharge;
  final String tags;
  final num weight;

  ProductDetails({
    required this.title,
    required this.description,
    required this.images,
    required this.purity,
    required this.sku,
    required this.makingCharge,
    required this.type,
    required this.tags,
    required this.weight,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      title: json['title'],
      description: json['description'],
      images: List<String>.from(json['images']),
      purity: json['purity'],
      sku: json['sku'],
      type: json['type'],
      makingCharge: json['makingCharge'],
      tags: json['tags'],
      weight: json['weight'],
    );
  }
}
