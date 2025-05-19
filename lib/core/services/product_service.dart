import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io; 
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class ProductService {
  static final client = http.Client();
  static final _marketDataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get marketDataStream =>
      _marketDataStreamController.stream;

  static io.Socket? _socket;

  static Future<Map<String, dynamic>?> initializeSocketConnection() async {
    final link = await getServer();
    _socket = io.io(link, {
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'secret': 'aurify@123',
      },
    });

    // Debugging connection lifecycle events
    _socket?.on('connect', (_) async {
      List<String> productSymbols = await fetchProductSymbols();
      requestMarketData(productSymbols);
    });

    _socket?.on('connect_error', (error) {
      log('Connection failed: $error');
    });

    _socket?.on('connect_timeout', (_) {
      log('Connection timeout!');
    });

    _socket?.on('disconnect', (_) {
      log('Disconnected from WebSocket');
    });

    // Handle incoming messages
    _socket?.on('market-data', (data) async {
      if (data is Map<String, dynamic>) {
        _marketDataStreamController.add(data);
      }
    });

    // Other events (optional)
    _socket?.on('error', (error) {
      log('Received error event: $error');
    });

    // Start the connection
    _socket?.connect();
    return null;
  }

  static Future<double?> getSpotRate() async {
    try {
      var response = await client.get(
        Uri.parse('$newBaseUrl/get-spotrates/$adminId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        num goldSpotRate = responseData['info']['goldBidSpread'];
        // log(goldSpotRate.toString());
        // log(response.body);
        return goldSpotRate.toDouble();
      } else {
        // log(response.body);
        return null;
      }
    } catch (e) {
      // print(e.toString());
      return null;
    }
  }

  static Future<List<String>> fetchProductSymbols() async {
    try {
      // Get adminId and categoryId from storage
      final adminId = await LocalStorage.getString('adminId') ?? '';
      final categoryId = await LocalStorage.getString('categoryId') ?? '';

      log('Fetching product symbols with adminId: $adminId, categoryId: $categoryId');

      // Fetch products using the flexible fetching method
      final products = await fetchProducts(adminId, categoryId);

      // Extract product identifiers (using SKU as symbols) from products with stock=true
      return products
          .where((product) => product['stock'] == true)
          .map((product) => product['sku'].toString())
          .toList();
    } catch (e) {
      log('Error fetching product symbols: ${e.toString()}');
      return [];
    }
  }

  static void requestMarketData(List<String> symbols) {
    if (symbols.isEmpty) {
      log('Warning: No symbols provided for market data request');
    }
    _socket?.emit('request-data', [symbols]);
  }

  static Future<String> getServer() async {
    try {
      var response = await client.get(
        Uri.parse('https://api.aurify.ae/user/get-server'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['info'] != null) {
          String? serverUrl = responseData['info']['serverURL'];
          if (serverUrl == null || serverUrl.isEmpty) {
            log('Server URL is empty or null');
          }
          return serverUrl ?? ''; // Ensure a string is returned
        }
      }
      log('Failed to get server URL, status: ${response.statusCode}');
      return ''; // Return an empty string if the response isn't valid
    } catch (e) {
      log('Error getting server: ${e.toString()}');
      return ''; // Ensure no null values are returned
    }
  }

  static Future<int> getProductCount(String categoryId) async {
    try {
      final url = 'https://api.nova.aurify.ae/user/product-count/$categoryId';
      log('Checking product count for categoryId: $categoryId');
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final int count = responseData['productCount'] ?? 0;
          log('Product count for categoryId $categoryId: $count');
          return count;
        }
      }
      
      log('Failed to get product count, status: ${response.statusCode}');
      return 0;
    } catch (e) {
      log('Error getting product count: ${e.toString()}');
      return 0;
    }
  }

  static Future<Map<String, dynamic>> checkCategoryStatus() async {
  try {
    final userId = await LocalStorage.getString('userId') ?? '';
    if (userId.isEmpty) {
      log('Error: userId is empty for category status check');
      return {
        'hasCategoryId': false,
        'hasUserSpotRateId': false,
        'categoryId': '',
        'userSpotRateId': ''
      };
    }

    final url = 'https://api.nova.aurify.ae/user/check-category-status/$userId';
    log('Checking category status for userId: $userId');
    
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'X-Secret-Key': secreteKey,
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['user'] != null) {
        final user = responseData['user'];
        log('User category status: hasCategoryId=${user['hasCategoryId']}, hasUserSpotRateId=${user['hasUserSpotRateId']}');
        
        return {
          'hasCategoryId': user['hasCategoryId'] ?? false,
          'hasUserSpotRateId': user['hasUserSpotRateId'] ?? false,
          'categoryId': user['categoryId'] ?? '',
          'userSpotRateId': user['userSpotRateId'] ?? ''
        };
      }
    }
    
    log('Failed to get category status, status: ${response.statusCode}');
    return {
      'hasCategoryId': false,
      'hasUserSpotRateId': false,
      'categoryId': '',
      'userSpotRateId': ''
    };
  } catch (e) {
    log('Error checking category status: ${e.toString()}');
    return {
      'hasCategoryId': false,
      'hasUserSpotRateId': false,
      'categoryId': '',
      'userSpotRateId': ''
    };
  }
}

// Updated fetchProducts function
static Future<List<dynamic>> fetchProducts([String? adminId, String? categoryId]) async {
  try {
    // First check the user's category status
    final userStatus = await checkCategoryStatus();
    final bool hasCategoryId = userStatus['hasCategoryId'];
    final bool hasUserSpotRateId = userStatus['hasUserSpotRateId'];
    
    // Get stored values if parameters aren't provided
    String finalAdminId = adminId ?? '67f37dfe4831e0eb637d09f1';
    String finalCategoryId = categoryId ?? 
                            (hasCategoryId ? userStatus['categoryId'] : '');
    String userSpotRateId = hasUserSpotRateId ? userStatus['userSpotRateId'] : '';
    
    // Determine which parameters to use based on user status
    String baseUrl = 'https://api.nova.aurify.ae/user/get-product';
    String url;
    
    if (hasCategoryId) {
      // Use categoryId with null adminId and null userSpotRateId
      url = '$baseUrl/null/$finalCategoryId/null';
      log('Using categoryId: $finalCategoryId (adminId and userSpotRateId set to null)');
    } else if (hasUserSpotRateId) {
      // Use userSpotRateId with null adminId and null categoryId
      url = '$baseUrl/null/null/$userSpotRateId';
      log('Using userSpotRateId: $userSpotRateId (adminId and categoryId set to null)');
    } else {
      // Use adminId with null categoryId and null userSpotRateId
      url = '$baseUrl/$finalAdminId/null/null';
      log('Using adminId: $finalAdminId (categoryId and userSpotRateId set to null)');
    }
    
    log('Making request to URL: $url');
    
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'X-Secret-Key': secreteKey,
        'Content-Type': 'application/json',
      },
    );

    log('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log('Response data: ${responseData.toString()}');

      if (responseData['success'] == true && responseData['data'] != null) {
        // Filter products where stock is true
        List<dynamic> allProducts = responseData['data'];
        List<dynamic> inStockProducts = allProducts.where((product) => 
          product['stock'] == true
        ).toList();
        
        log('Filtered ${inStockProducts.length} products with stock=true out of ${allProducts.length} total products');
        return inStockProducts;
      } else {
        log('API returned success=false or null data');
        return [];
      }
    } else {
      log('API returned error status code: ${response.statusCode}');
      log('Response body: ${response.body}');
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } catch (e) {
    log('Error fetching products: ${e.toString()}');
    return [];
  }
}

  static Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
    try {
      log('Fixing price with payload: ${payload.toString()}');
      var response = await client.put(Uri.parse(fixPriceUrl),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        return MessageModel.fromJson({'success': true});
      } else {
        log('Failed to fix price, status: ${response.statusCode}');
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error fixing price: ${e.toString()}');
      return null;
    }
  }

  // In ProductService.bookProducts method - replace the existing logging section:

static Future<MessageModel?> bookProducts(
    Map<String, dynamic> payload) async {
  try {
    final id = await LocalStorage.getString('userId');
    if (id == null || id.isEmpty) {
      log('Error: userId is empty');
      return MessageModel.fromJson(
          {'success': false, 'message': 'User ID is missing'});
    }

    // Format the booking data to match the expected structure
    final List<Map<String, dynamic>> bookingData = 
        (payload["bookingData"] as List).map((item) {
      
      // Log each item being processed
      log('Processing booking item: ${jsonEncode(item)}');
      
      return {
        "productId": item["productId"],
        "makingCharge": item["makingCharge"] ?? 0.0
      };
    }).toList(); 

    // Prepare the updated payload
    final Map<String, dynamic> formattedPayload = {
      "paymentMethod": payload["paymentMethod"],
      "bookingData": bookingData,
      // Optional fields that might be needed
      "deliveryDate": payload["deliveryDate"],
      "address": payload["address"],
      "contact": payload["contact"]
    };

    final url = bookingUrl.replaceFirst('{userId}', id.toString());
    
    // Enhanced logging
    log('=== BOOKING REQUEST DETAILS ===');
    log('URL: $url');
    log('Request Headers: {X-Secret-Key: [HIDDEN], Content-Type: application/json}');
    log('Request Body: ${jsonEncode(formattedPayload)}');
    log('Formatted booking data count: ${bookingData.length}');
    log('================================');

    var response = await client.post(Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(formattedPayload));

    log('=== BOOKING RESPONSE DETAILS ===');
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');
    log('=================================');

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      log('✅ Booking successful');
      return MessageModel.fromJson(responseData);
    } else {
      log('❌ Booking failed with status: ${response.statusCode}');
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return MessageModel.fromJson(responseData);
    }
  } catch (e) {
    log('💥 Error booking products: ${e.toString()}');
    return null;
  }
}

  static void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _marketDataStreamController.close();
  }
}