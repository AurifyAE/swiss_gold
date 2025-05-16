// lib/app/data/models/bank_model.dart

class BankResponse {
  final bool success;
  final BankInfo bankInfo;
  final String message;

  BankResponse({
    required this.success,
    required this.bankInfo,
    required this.message,
  });

  factory BankResponse.fromJson(Map<String, dynamic> json) {
    return BankResponse(
      success: json['success'],
      bankInfo: BankInfo.fromJson(json['bankInfo']),
      message: json['message'],
    );
  }
}

class BankInfo {
  final String id;
  final List<BankDetails> bankDetails;

  BankInfo({
    required this.id,
    required this.bankDetails,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      id: json['_id'],
      bankDetails: (json['bankDetails'] as List)
          .map((item) => BankDetails.fromJson(item))
          .toList(),
    );
  }
}

class BankDetails {
  final String id;
  final String holderName;
  final String bankName;
  final String accountNumber;
  final String iban;
  final String ifsc;
  final String swift;
  final String branch;
  final String city;
  final String country;
  final String logo;

  BankDetails({
    required this.id,
    required this.holderName,
    required this.bankName,
    required this.accountNumber,
    required this.iban,
    required this.ifsc,
    required this.swift,
    required this.branch,
    required this.city,
    required this.country,
    required this.logo,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['_id'],
      holderName: json['holderName'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      iban: json['iban'],
      ifsc: json['ifsc'],
      swift: json['swift'],
      branch: json['branch'],
      city: json['city'],
      country: json['country'],
      logo: json['logo'],
    );
  }
}