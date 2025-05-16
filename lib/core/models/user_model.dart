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
    // Check which field contains the user ID
    String id = '';
    if (json.containsKey('_id')) {
      id = json['_id'];
    } else if (json.containsKey('userId')) {
      id = json['userId'];
    } else if (json.containsKey('info') && json['info'] is Map && json['info'].containsKey('_id')) {
      id = json['info']['_id'];
    }
    
    return UserModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      userId: id,
    );
  }

  factory UserModel.withError(Map<String, dynamic> json) {
    return UserModel(
      message: json['message'] ?? 'An error occurred',
      success: json['success'] ?? false,
      userId: '', // Empty string instead of null
    );
  }
}