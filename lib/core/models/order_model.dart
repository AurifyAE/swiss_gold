class OrderModel {
  final bool success;
  final String message;
  final List<OrderData> data;
  final Pagination? pagination;

  OrderModel({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? List<OrderData>.from(
              json['data'].map((x) => OrderData.fromJson(x)),
            )
          : [],
    );
  }
}

class OrderData {
  final String id;
  final num totalPrice;
  final num totalWeight;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String transactionId;
  final String orderDate;
  final CustomerData customer;
  final List<Item> item;
  final String? orderRemark;
  final String? pricingOption;
  final num premiumAmount;
  final num discountAmount;
  final String? deliveryDate;

  OrderData({
    required this.id,
    required this.totalPrice,
    required this.totalWeight,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionId,
    required this.orderDate,
    required this.customer,
    required this.item,
    this.orderRemark,
    this.pricingOption,
    this.premiumAmount = 0,
    this.discountAmount = 0,
    this.deliveryDate,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['_id'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      totalWeight: json['totalWeight'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      orderDate: json['orderDate'] ?? '',
      deliveryDate: json['deliveryDate'] ?? json['orderDate'],
      customer: CustomerData.fromJson(json['customer'] ?? {}),
      item: json['items'] != null
          ? List<Item>.from(json['items'].map((x) => Item.fromJson(x)))
          : [],
      orderRemark: json['orderRemark'],
      pricingOption: json['pricingOption'],
      premiumAmount: json['premiumAmount'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
    );
  }
}

class CustomerData {
  final String id;
  final String name;
  final String email;
  final String address;
  final dynamic contact;

  CustomerData({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.contact,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
    );
  }
}

class Item {
  final String id;
  final String status;
  final int quantity;
  final ProductData? product;

  Item({
    required this.id,
    required this.status,
    required this.quantity,
    this.product,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? '',
      status: json['itemStatus'] ?? '',
      quantity: json['quantity'] ?? 0,
      product: json['product'] != null
          ? ProductData.fromJson(json['product'])
          : null,
    );
  }
}

class ProductData {
  final String id;
  final String title;
  final String description;
  final num price;
  final num weight;
  final num purity;
  final bool stock;
  final String sku;
  final List<dynamic> images;

  ProductData({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.weight,
    required this.purity,
    required this.stock,
    required this.sku,
    required this.images,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    // Extract the first image URL from the images array
    List<String> imageUrls = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        // Handle array of objects with url property
        for (var img in json['images']) {
          if (img is Map && img.containsKey('url')) {
            imageUrls.add(img['url']);
          } else if (img is String) {
            imageUrls.add(img);
          }
        }
      }
    }

    return ProductData(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      weight: json['weight'] ?? 0,
      purity: json['purity'] ?? 0,
      stock: json['stock'] ?? false,
      sku: json['sku'] ?? '',
      images: imageUrls,
    );
  }
}

class Pagination {
  final num totalCount;
  final num totalPage;
  final num currentPage;

  Pagination({
    required this.totalCount,
    required this.totalPage,
    required this.currentPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalCount: json['totalOrders'] ?? 0,
      totalPage: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}