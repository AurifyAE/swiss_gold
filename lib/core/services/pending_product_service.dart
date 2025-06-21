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
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return PendingOrderResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load pending orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pending orders: $e');
    }
  }
}