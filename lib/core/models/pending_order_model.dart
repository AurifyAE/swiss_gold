class PendingOrderResponse {
  final bool success;
  final List<PendingOrder> data;
  final String message;

  PendingOrderResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PendingOrderResponse.fromJson(Map<String, dynamic> json) {
    return PendingOrderResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => PendingOrder.fromJson(item))
          .toList() ?? [],
      message: json['message'] ?? '',
    );
  }
}

class PendingOrder {
  final String id;
  final String adminId;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final double totalWeight;
  final String transactionId;
  final String orderStatus;
  final String? orderRemark;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime notificationSentAt;
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PendingOrder({
    required this.id,
    required this.adminId,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.totalWeight,
    required this.transactionId,
    required this.orderStatus,
    this.orderRemark,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.notificationSentAt,
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PendingOrder.fromJson(Map<String, dynamic> json) {
    return PendingOrder(
      id: json['_id'] ?? '',
      adminId: json['adminId'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
      transactionId: json['transactionId'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      orderRemark: json['orderRemark'],
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      notificationSentAt: DateTime.parse(json['notificationSentAt']),
      orderDate: DateTime.parse(json['orderDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class OrderItem {
  final Pendingproduct productId;
  final int quantity;
  final double fixedPrice;
  final double productWeight;
  final double makingCharge;
  final DateTime addedAt;
  final String itemStatus;
  final bool select;
  final String id;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.fixedPrice,
    required this.productWeight,
    required this.makingCharge,
    required this.addedAt,
    required this.itemStatus,
    required this.select,
    required this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: Pendingproduct.fromJson(json['productId']),
      quantity: json['quantity'] ?? 0,
      fixedPrice: (json['fixedPrice'] ?? 0).toDouble(),
      productWeight: (json['productWeight'] ?? 0).toDouble(),
      makingCharge: (json['makingCharge'] ?? 0).toDouble(),
      addedAt: DateTime.parse(json['addedAt']),
      itemStatus: json['itemStatus'] ?? '',
      select: json['select'] ?? false,
      id: json['_id'] ?? '',
    );
  }
}

class Pendingproduct {
  final String id;
  final String title;
  final String description;
  final List<ProductImage> images;
  final double price;
  final double weight;
  final int purity;
  final bool stock;
  final String sku;
  final String addedBy;
  final String? addedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pendingproduct({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.weight,
    required this.purity,
    required this.stock,
    required this.sku,
    required this.addedBy,
    this.addedByUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pendingproduct.fromJson(Map<String, dynamic> json) {
    return Pendingproduct(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((item) => ProductImage.fromJson(item))
          .toList() ?? [],
      price: (json['price'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      purity: json['purity'] ?? 0,
      stock: json['stock'] ?? false,
      sku: json['sku'] ?? '',
      addedBy: json['addedBy'] ?? '',
      addedByUser: json['addedByUser'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ProductImage {
  final String url;
  final String key;
  final String id;

  ProductImage({
    required this.url,
    required this.key,
    required this.id,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] ?? '',
      key: json['key'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
