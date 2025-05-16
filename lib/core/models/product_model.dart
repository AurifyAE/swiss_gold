class ProductModel {
  final bool success;
  final List<Product> data;
  final Page? page;

  ProductModel({
    required this.success,
    required this.data,
    this.page,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      success: json['success'] ?? false,
      data: json['data'] != null 
          ? List<Product>.from(
              json['data'].map(
                (data) => Product.fromJson(data),
              ),
            )
          : [],
      page: json['page'] != null ? Page.fromJson(json['page']) : null,
    );
  }
}

class Page {
  final int currentPage;
  final int totalPage;

  Page({
    required this.currentPage,
    required this.totalPage,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      currentPage: json['currentPage'] ?? 1,
      totalPage: json['totalPage'] ?? 1,
    );
  }
}

class Product {
  final String pId;
  final String title;
  final num price;
  final bool stock;
  final num makingCharge;
  final String? type; // Changed to nullable
  final String? pricingType;
  final num? markingCharge;
  final num? value;
  final bool? isActive;
  final String desc;
  final num weight;
  final num purity;
  final List<ProductImage> prodImgs;
  final String? sku;
  final String? addedBy;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.pId,
    required this.title,
    required this.price,
    required this.stock,
    this.type, // Changed to optional
    required this.desc,
    required this.prodImgs,
    required this.makingCharge,
    required this.weight,
    required this.purity,
    this.pricingType,
    this.markingCharge,
    this.value,
    this.isActive,
    this.sku,
    this.addedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      pId: json['_id'],
      title: json['title'],
      price: json['price'],
      stock: json['stock'],
      type: json['type'], // This field isn't in your JSON
      desc: json['description'],
      makingCharge: json['makingCharge'] ?? 0, // Added default value
      weight: json['weight'],
      purity: json['purity'],
      pricingType: json['pricingType'],
      markingCharge: json['markingCharge'] ?? 0, // Added default value
      value: json['value'] ?? 0, // Added default value
      isActive: json['isActive'],
      sku: json['sku'],
      addedBy: json['addedBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      prodImgs: List<ProductImage>.from(
        (json['images'] as List).map(
          (data) => ProductImage.fromJson(data),
        ),
      ),
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
      url: json['url'],
      key: json['key'],
      id: json['_id'],
    );
  }
}