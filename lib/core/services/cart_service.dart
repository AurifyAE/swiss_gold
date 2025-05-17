import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/cart_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class CartService {
  static final client = http.Client();

  static Future<CartModel?> getCart() async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = getCartUrl.replaceFirst('{userId}', id.toString());
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return CartModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<MessageModel?> updateQuantityFromHome(
      String pId, Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');
      log(payload.toString());
      log(id.toString());

      final url = updateQuantityFromHomeUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', pId);
      log(url);
      var response = await client.put(Uri.parse(url),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error updating quantity from home: $e');
      return null;
    }
  }

  static Future<MessageModel?> updateCartQuantity(
      String productId, int quantity) async {
    try {
      final userId = await LocalStorage.getString('userId');
      final adminId = await LocalStorage.getString('adminId') ?? 'default'; // Get adminId or use default
      
      final url = 'https://api.nova.aurify.ae/user/cart/update-quantity/$adminId/$userId/$productId';
      log('Updating cart quantity URL: $url');
      log('Payload: {"quantity": $quantity}');
      
      var response = await client.put(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "quantity": quantity
        })
      );
      
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error updating cart quantity: $e');
      return null;
    }
  }

  static Future<void> confirmQuantity(Map<String, dynamic> payload) async {
    try {
      var response = await client.post(Uri.parse(confirmQuantityUrl),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        // log(response.body);
      } else {
        // log(response.body);
      }
    } catch (e) {
      // log(e.toString());
    }
  }

  static Future<MessageModel?> incrementQuantity(Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = incrementQuantityUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', payload['pId']);
      log('Increment URL: $url');
      log('Payload: $payload');
      
      var response = await client.patch(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error in incrementQuantity: $e');
      return null;
    }
  }

  static Future<MessageModel?> decrementQuantity(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = decrementQuantityUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', payload['pId']);
      var response = await client.patch(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error in decrementQuantity: $e');
      return null;
    }
  }

  static Future<MessageModel?> deleteFromCart(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = deleteFromCartUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', payload['pId']);

      var response = await client.delete(Uri.parse(url),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error in deleteFromCart: $e');
      return null;
    }
  }

  static Future<MessageModel?> clearCart() async {
    try {
      final userId = await LocalStorage.getString('userId');
      
      // Assuming the endpoint for clearing cart follows similar pattern
      // If you need a different endpoint, replace with the correct one
      final url = 'https://api.nova.aurify.ae/user/cart/clear/$userId';
      
      log('Clearing cart URL: $url');
      
      var response = await client.delete(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );
      
      log('Clear cart response status: ${response.statusCode}');
      log('Clear cart response body: ${response.body}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error clearing cart: $e');
      return MessageModel(success: false, message: e.toString());
    }
  }
}