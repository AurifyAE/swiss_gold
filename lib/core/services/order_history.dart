import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/order_model.dart';
import 'package:swiss_gold/core/models/pricing_method_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class OrderHistoryService {
  static final client = http.Client();
  
  static Future<OrderModel?> getOrderHistory(String page, String status) async {
    try {
      final userId = await LocalStorage.getString('userId');
      final adminId = '67f37dfe4831e0eb637d09f1'; // Get adminId if available
      
      // Build the URL with query parameters
      String baseUrl = 'https://api.nova.aurify.ae/user/fetch-order/$adminId/$userId';
      
      // Add query parameters
      Map<String, String> queryParams = {
        'page': page,
        'limit': '10', // Default limit
      };
      
      if (status.isNotEmpty && status != 'All') {
        queryParams['orderStatus'] = status;
      }
      
      Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      
      log('Fetching orders from: $uri');
      
      var response = await client.get(
        uri,
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log('Order response: ${response.body}');
        return OrderModel.fromJson(responseData);
      } else {
        log('Error fetching orders: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Exception in getOrderHistory: ${e.toString()}');
      return null;
    }
  }

  static Future<PricingMethodModel?> getPricing(String type) async {
    try {
      final id = await LocalStorage.getString('userId');
      log(id.toString());

      final url = pricingUrl.replaceFirst('{type}', type);
      log(url);
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        // log(response.body);
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return PricingMethodModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}