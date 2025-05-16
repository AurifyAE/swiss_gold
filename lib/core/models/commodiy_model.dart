class CommodityModel {
  final bool success;
  final List<String> commodities;
  final String message;

  // Constructor
  CommodityModel({
    required this.success,
    required this.commodities,
    required this.message,
  });

  // Factory method to create a CommodityModel from JSON
  factory CommodityModel.fromJson(Map<String, dynamic> json) {
    return CommodityModel(
      success: json['success'],
      commodities: List<String>.from(json['commodities']),
      message: json['message'],
    );
  }

  
}
