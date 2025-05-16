// class WishlistModel {
//   final bool success;
//   final String message;
//   final List<WishlistInfo> data;

//   WishlistModel(
//       {required this.success, required this.message, required this.data});

//   factory WishlistModel.fromJson(Map<String, dynamic> json) {
//     return WishlistModel(
//       success: json['success'],
//       message: json['message'],
//       data: (json['info'] as List)
//           .map((data) => WishlistInfo.fromJson(data))
//           .toList(),
//     );
//   }
// }

// class WishlistInfo {
//   final String id;
//   final String userId;
//   final List<WishItem> items;
//   final String updatedAt;

//   WishlistInfo({
//     required this.id,
//     required this.userId,
//     required this.items,
//     required this.updatedAt,
//   });

//   factory WishlistInfo.fromJson(Map<String, dynamic> json) {
//     return WishlistInfo(
//       id: json['_id'],
//       userId: json['userId'],
//       items: (json['items'] as List).map((i) => WishItem.fromJson(i)).toList(),
//       updatedAt: json['updatedAt'],
//     );
//   }
// }

// class WishItem {
//   final String productId;
//   final ProductDetails productDetails;

//   WishItem({
//     required this.productId,
//     required this.productDetails,
//   });

//   factory WishItem.fromJson(Map<String, dynamic> json) {
//     return WishItem(
//       productId: json['productId'],
//       productDetails: ProductDetails.fromJson(json['productDetails']),
//     );
//   }
// }

// class ProductDetails {
//   final String title;
//   final String description;
//   final List<String> images;
//   final num price;
//   final num purity;
//   final num makingCharge;
//   final String sku;
//   final String type;
//   final String tags;
//   final num weight;
//   final String subCategory;
//   final String mainCategory;

//   ProductDetails({
//     required this.title,
//     required this.description,
//     required this.images,
//     required this.price,
//     required this.purity,
//     required this.sku,
//     required this.type,
//     required this.makingCharge,
//     required this.tags,
//     required this.weight,
//     required this.subCategory,
//     required this.mainCategory,
//   });

//   factory ProductDetails.fromJson(Map<String, dynamic> json) {
//     return ProductDetails(
//       title: json['title'],
//       description: json['description'],
//       images: List<String>.from(json['images']),
//       price: json['price'],
//       purity: json['purity'],
//       makingCharge: json['makingCharge'],
//       sku: json['sku'],
//       type: json['type'],
//       tags: json['tags'],
//       weight: json['weight'],
//       subCategory: json['subCategory'],
//       mainCategory: json['mainCategory'],
//     );
//   }
// }
