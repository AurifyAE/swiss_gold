import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _notificationService.getNotifications();
      _notifications = result['notifications'] as List<NotificationModel>;
      _unreadCount = result['unreadCount'] as int;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markNotificationAsRead(notificationId);
      
      if (success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(read: true);
          // After marking as read, decrement the unread count
          if (_unreadCount > 0) {
            _unreadCount--;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      
      if (success) {
        // Check if the notification was unread before removing
        final notification = _notifications.firstWhere(
          (n) => n.id == notificationId,
          orElse: () => NotificationModel(
            id: '', 
            message: '', 
            read: true, 
            createdAt: DateTime.now()
          ),
        );
        
        // Remove from local state
        _notifications.removeWhere((n) => n.id == notificationId);
        
        // If the notification was unread, decrement the unread count
        if (!notification.read && _unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Method to get a specific notification by ID
  NotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Method to filter notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }
  
  // Method to get notifications related to a specific order
  List<NotificationModel> getNotificationsByOrderId(String orderId) {
    return _notifications.where((notification) => notification.orderId == orderId).toList();
  }
}