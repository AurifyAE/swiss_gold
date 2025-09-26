// core/models/user_model.dart
import 'dart:developer';

class UserModel {
  final String message;
  final bool success;
  final String userId;

  UserModel({
    required this.message,
    required this.success,
    required this.userId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    log('UserModel: Parsing JSON: $json'); // Debug log to inspect response

    // Check which field contains the user ID
    String id = '';
    if (json.containsKey('user') && json['user'] is Map && json['user'].containsKey('_id')) {
      id = json['user']['_id'] ?? '';
      log('UserModel: Extracted userId from user._id: $id');
    } else if (json.containsKey('_id')) {
      id = json['_id'] ?? '';
      log('UserModel: Extracted userId from _id: $id');
    } else if (json.containsKey('userId')) {
      id = json['userId'] ?? '';
      log('UserModel: Extracted userId from userId: $id');
    } else if (json.containsKey('info') && json['info'] is Map && json['info'].containsKey('_id')) {
      id = json['info']['_id'] ?? '';
      log('UserModel: Extracted userId from info._id: $id');
    } else {
      log('UserModel: No userId found in JSON');
    }

    return UserModel(
      message: json['message'] ?? 'No message provided',
      success: json['success'] ?? false,
      userId: id,
    );
  }

  factory UserModel.withError(Map<String, dynamic> json) {
    log('UserModel: Creating error model: $json');
    return UserModel(
      message: json['message'] ?? 'An error occurred',
      success: json['success'] ?? false,
      userId: '',
    );
  }
}