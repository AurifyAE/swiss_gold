import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'local_storage.dart';
import 'secrete_key.dart';

class NotificationService {
  final String baseUrl = 'https://api.nova.aurify.ae/user';
  final client = http.Client();

  Future<String?> _getUserId() async {
    // Get userId from local storage
    return await LocalStorage.getString('userId');
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final userId = await _getUserId();
      
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final response = await client.get(
        Uri.parse('$baseUrl/notifications/$userId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final List<dynamic> notificationsJson = responseData['data']['notifications'];
          return notificationsJson
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch notifications');
        }
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final userId = await _getUserId();
      
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      // Updated endpoint based on provided information
      final response = await client.patch(
        Uri.parse('$baseUrl/notifications/read/$userId/$notificationId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final userId = await _getUserId();
      
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final response = await client.delete(
        Uri.parse('$baseUrl/notifications/$userId/$notificationId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final userId = await _getUserId();
      
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final response = await client.get(
        Uri.parse('$baseUrl/notifications/$userId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          return responseData['data']['unreadCount'] ?? 0;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch unread count');
        }
      } else {
        throw Exception('Failed to load unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching unread count: $e');
    }
  }
}