import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';
import '../models/pending_order_model.dart';

class ApiService {

static Future<PendingOrderResponse> getPendingApprovalOrders(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$newBaseUrl/pending-approval-orders?userId=$userId'),
      headers: {
        'x-secret-key': secreteKey, 
        'Content-Type': 'application/json', 
      },
    ).timeout(const Duration(seconds: 30)); // Add timeout

    print('📥 [GET_PENDING] Response: ${response.statusCode}');
    print('📥 [GET_PENDING] Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return PendingOrderResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load pending orders: ${response.statusCode}');
    }
  } catch (e) {
    print('📥 [GET_PENDING] Error: $e');
    throw Exception('Error fetching pending orders: $e');
  }
}

  static Future<bool> approveOrderItem({
    required String orderId,
    required String itemId,  
    required String userId,
    required int quantity, 
    required double fixedPrice,
    required double productWeight,
  }) async {
    print('🟢 [APPROVE] Starting approval process...');
    print('🟢 [APPROVE] Parameters:');
    print('   - orderId: $orderId');
    print('   - itemId: $itemId');
    print('   - userId: $userId');
    print('   - quantity: $quantity');
    print('   - fixedPrice: $fixedPrice');
    print('   - productWeight: $productWeight');
    
    try {
      // Try different endpoint paths - uncomment the one that works
      final url = 'https://api.nova.aurify.ae/user/approve-order-item/$orderId/$itemId';
      // final url = 'https://api.nova.aurify.ae/admin/approve-order-item/$orderId/$itemId';
      // final url = 'https://api.nova.aurify.ae/approve-order-item/$orderId/$itemId';
      print('🟢 [APPROVE] Request URL: $url');
      
      final requestBody = {
        'userId': userId,
        'quantity': quantity,
        'fixedPrice': fixedPrice,
        'productWeight': productWeight,
      };
      print('🟢 [APPROVE] Request body: ${json.encode(requestBody)}');
      
      final headers = {
        'x-secret-key': secreteKey,
        'Content-Type': 'application/json',
      };
      print('🟢 [APPROVE] Headers: ${headers.keys.join(', ')} (secret key length: ${secreteKey.length})');
      
      print('🟢 [APPROVE] Sending POST request...');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('🟢 [APPROVE] Response received:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Headers: ${response.headers}');
      print('   - Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('🟢 [APPROVE] ✅ SUCCESS - Order item approved successfully');
        return true;
      } else {
        print('🟢 [APPROVE] ❌ FAILED - Status code: ${response.statusCode}');
        print('🟢 [APPROVE] Error response body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('🟢 [APPROVE] ❌ EXCEPTION occurred:');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      throw Exception('Error approving order item: $e');
    }
  }

  static Future<bool> rejectOrderItem({
    required String orderId,
    required String itemId,
    required String userId,
    required String rejectionReason,
  }) async {
    print('🔴 [REJECT] Starting rejection process...');
    print('🔴 [REJECT] Parameters:');
    print('   - orderId: $orderId');
    print('   - itemId: $itemId');
    print('   - userId: $userId');
    print('   - rejectionReason: $rejectionReason');
    
    try {
      // Try different endpoint paths - uncomment the one that works
      final url = 'https://api.nova.aurify.ae/user/reject-order-item/$orderId/$itemId';
      // final url = 'https://api.nova.aurify.ae/admin/reject-order-item/$orderId/$itemId';
      // final url = 'https://api.nova.aurify.ae/reject-order-item/$orderId/$itemId';
      print('🔴 [REJECT] Request URL: $url');
      
      final requestBody = {
        'userId': userId,
        'rejectionReason': rejectionReason,
      };
      print('🔴 [REJECT] Request body: ${json.encode(requestBody)}');
      
      final headers = {
        'x-secret-key': secreteKey,
        'Content-Type': 'application/json',
      };
      print('🔴 [REJECT] Headers: ${headers.keys.join(', ')} (secret key length: ${secreteKey.length})');
      
      print('🔴 [REJECT] Sending POST request...');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('🔴 [REJECT] Response received:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Headers: ${response.headers}');
      print('   - Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('🔴 [REJECT] ✅ SUCCESS - Order item rejected successfully');
        return true;
      } else {
        print('🔴 [REJECT] ❌ FAILED - Status code: ${response.statusCode}');
        print('🔴 [REJECT] Error response body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('🔴 [REJECT] ❌ EXCEPTION occurred:');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      throw Exception('Error rejecting order item: $e');
    }
  }
}