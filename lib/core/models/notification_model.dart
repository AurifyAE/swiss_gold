class NotificationModel {
  final String id;
  final String message;
  final bool read;
  final DateTime createdAt;
  final String? orderId;
  final String? itemId;
  final String? type;

  NotificationModel({
    required this.id,
    required this.message,
    required this.read,
    required this.createdAt,
    this.orderId,
    this.itemId,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      orderId: json['orderId'],
      itemId: json['itemId'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': message,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'orderId': orderId,
      'itemId': itemId,
      'type': type,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? message,
    bool? read,
    DateTime? createdAt,
    String? orderId,
    String? itemId,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
    );
  }
}