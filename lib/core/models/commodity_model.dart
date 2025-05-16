// import 'dart:convert';

// CommodityModel commodityModelFromMap(String str) =>
//     CommodityModel.fromMap(json.decode(str));

// String commodityModelToMap(CommodityModel data) =>
//     json.encode(data.toMap());

// class CommodityModel {
//   final bool success;
//   final List<String> commodities;
//   final String message;

//   CommodityModel({
//     required this.success,
//     required this.commodities,
//     required this.message,
//   });

//   CommodityModel copyWith({
//     bool? success,
//     List<String>? commodities,
//     String? message,
//   }) =>
//       CommodityModel(
//         success: success ?? this.success,
//         commodities: commodities ?? this.commodities,
//         message: message ?? this.message,
//       );

//   factory CommodityModel.fromMap(Map<String, dynamic> json) =>
//       CommodityModel(
//         success: json["success"],
//         commodities: List<String>.from(json["commodities"].map((x) => x)),
//         message: json["message"],
//       );

//   Map<String, dynamic> toMap() => {
//         "success": success,
//         "commodities": List<dynamic>.from(commodities.map((x) => x)),
//         "message": message,
//       };
// }
