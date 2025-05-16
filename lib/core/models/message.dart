class MessageModel {
  final String? message;
  final bool? success;

    MessageModel({this.message, required this.success});


  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(message: json['message'], success: json['success']);
  }

  factory MessageModel.withError(Map<String, dynamic> json) {
    return MessageModel(message: json['message'], success: json['success']);
  }
}
