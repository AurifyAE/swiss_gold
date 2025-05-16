
class PricingMethodModel {
  final Data data;
  final bool status;

  PricingMethodModel({required this.data, required this.status});

  factory PricingMethodModel.fromJson(Map<String, dynamic> json) {
    return PricingMethodModel(
        status: json['success'], data: Data.fromJson(json['data']));
  }
}

class Data {
  final String id;
  final String createdBy;
  final String methodType;
  final String pricingType;
  final int value;
  final DateTime createdAt;
  final DateTime updatedAt;

  Data({
    required this.id,
    required this.createdBy,
    required this.methodType,
    required this.pricingType,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a Data instance from JSON
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["_id"],
      createdBy: json["createdBy"],
      methodType: json["methodType"],
      pricingType: json["pricingType"],
      value: json["value"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}
