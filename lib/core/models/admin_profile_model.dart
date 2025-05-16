class CompanyProfileModel {
  final String message;
  final bool success;
  final String userId;
  final UserDetails userDetails;

  CompanyProfileModel({
    required this.message,
    required this.success,
    required this.userId,
    required this.userDetails,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      userId: json['userId'] ?? '',
      userDetails: UserDetails.fromJson(json['userDetails'] ?? {}),
    );
  }
}

class UserDetails {
  final String name;
  final String email;
  final int contact;
  final String address;
  final String? categoryId;  // Made nullable
  final double cashBalance;
  final double goldBalance;
  final String? categoryName;  // Made nullable

  UserDetails({
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    this.categoryId,  // Optional
    required this.cashBalance,
    required this.goldBalance,
    this.categoryName,  // Optional
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? 0,
      address: json['address'] ?? '',
      categoryId: json['categoryId'],  // Allow null
      cashBalance: (json['cashBalance'] ?? 0).toDouble(),
      goldBalance: (json['goldBalance'] ?? 0).toDouble(),
      categoryName: json['categoryName'],  // Allow null
    );
  }
}