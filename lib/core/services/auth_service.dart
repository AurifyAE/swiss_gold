import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/models/user_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class AuthService {
  static final client = http.Client();
  static const String baseUrl = 'https://api.nova.aurify.ae/user';
  static const String adminId = '67f37dfe4831e0eb637d09f1';

  static Future<UserModel?> login(Map<String, dynamic> payload) async {
    log('AuthService: Starting login request with payload: $payload');
    try {
      log('AuthService: Sending POST request to $baseUrl/login');
      var response = await client.post(
        Uri.parse(loginUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload),
      );

      log('AuthService: Login response status: ${response.statusCode}');
      log('AuthService: Login response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log('AuthService: Parsed login response: $responseData');

        String userId = responseData['user']?['_id'] ??
                        responseData['_id'] ??
                        responseData['userId'] ??
                        (responseData['info']?['_id'] ?? '');
        log('AuthService: Extracted userId: $userId');

        if (userId.isNotEmpty) {
          log('AuthService: Storing user data in local storage');
          await Future.wait([
            LocalStorage.setString({'userId': userId}),
            if (responseData.containsKey('userDetails')) ...[
              LocalStorage.setString({'userName': responseData['userDetails']['name'] ?? 'User'}),
              LocalStorage.setString({'mobile': (responseData['userDetails']['contact'] ?? '').toString()}),
              if (responseData['userDetails'].containsKey('categoryId'))
                LocalStorage.setString({'categoryId': responseData['userDetails']['categoryId'] ?? ''}),
              if (responseData['userDetails'].containsKey('categoryName'))
                LocalStorage.setString({'category': responseData['userDetails']['categoryName'] ?? ''}),
            ] else if (responseData.containsKey('info')) ...[
              LocalStorage.setString({'userName': responseData['info']['userName'] ?? responseData['info']['companyName'] ?? 'User'}),
              LocalStorage.setString({'mobile': (responseData['info']['contact'] ?? '').toString()}),
            ],
          ]);
          log('AuthService: User data stored successfully');
        } else {
          log('AuthService: No userId found in response');
        }
        return UserModel.fromJson(responseData);
      } else {
        log('AuthService: Login failed with status ${response.statusCode}');
        try {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          return UserModel.withError(responseData);
        } catch (e) {
          log('AuthService: Failed to parse error response: ${response.body}');
          return UserModel.withError({
            'message': 'Server returned status ${response.statusCode}',
            'success': false
          });
        }
      }
    } catch (e, stackTrace) {
      log('AuthService: Login error: ${e.toString()}', stackTrace: stackTrace);
      return UserModel.withError({
        'message': 'An error occurred during login: $e',
        'success': false
      });
    }
  }

  static Future<UserModel?> register(Map<String, dynamic> payload) async {
    log('AuthService: Starting register request with payload: $payload');
    try {
      log('AuthService: Sending POST request to $baseUrl/add-users/$adminId');
      var response = await client.post(
        Uri.parse('$baseUrl/add-users/$adminId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload),
      );

      log('AuthService: Register response status: ${response.statusCode}');
      log('AuthService: Register response body: ${response.body}');

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        log('AuthService: Parsed register response: $responseData');
      } catch (e) {
        log('AuthService: Failed to parse register response: ${response.body}');
        return UserModel.withError({
          'message': 'Invalid response format from server',
          'success': false
        });
      }

      if ((response.statusCode == 200 || response.statusCode == 201) && responseData['success'] == true) {
        // Since the response doesn't contain user data, we create a minimal UserModel
        String userId = responseData['user']?['_id'] ?? '';
        log('AuthService: Extracted userId: $userId');

        if (userId.isNotEmpty) {
          log('AuthService: Storing user data in local storage');
          await Future.wait([
            LocalStorage.setString({'userId': userId}),
            LocalStorage.setString({'userName': payload['name'] ?? 'User'}),
            LocalStorage.setString({'mobile': (payload['contact'] ?? '').toString()}),
            if (payload.containsKey('categoryId'))
              LocalStorage.setString({'categoryId': payload['categoryId'] ?? ''}),
            // Note: categoryName is not available in payload or response, so we skip it
          ]);
          log('AuthService: User data stored successfully');
        } else {
          log('AuthService: No userId found in response, using payload data for UserModel');
        }

        // Return a UserModel with the available data
        return UserModel(
          success: true,
          message: responseData['message'] ?? 'User added successfully',
          userId: userId,
        );
      } else {
        log('AuthService: Registration failed with status ${response.statusCode}, response: $responseData');
        return UserModel.withError(responseData);
      }
    } catch (e, stackTrace) {
      log('AuthService: Registration error: ${e.toString()}', stackTrace: stackTrace);
      return UserModel.withError({
        'message': 'An error occurred during registration: $e',
        'success': false
      });
    }
  }

  static Future<List<Map<String, dynamic>>?> getCategories() async {
    log('AuthService: Starting getCategories request');
    try {
      log('AuthService: Sending GET request to $baseUrl/getCategories/$adminId');
      var response = await client.get(
        Uri.parse('$baseUrl/getCategories/$adminId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      log('AuthService: Get categories response status: ${response.statusCode}');
      log('AuthService: Get categories response body: ${response.body}');

      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        log('AuthService: Successfully fetched ${responseData['categories'].length} categories');
        return List<Map<String, dynamic>>.from(responseData['categories']);
      } else {
        log('AuthService: Failed to fetch categories with status ${response.statusCode}, response: $responseData');
        return null;
      }
    } catch (e, stackTrace) {
      log('AuthService: Get categories error: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }

  static Future<MessageModel?> changePassword(Map<String, dynamic> payload) async {
    log('AuthService: Starting changePassword request with payload: $payload');
    try {
      log('AuthService: Sending PUT request to $baseUrl/change-password');
      var response = await client.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload),
      );

      log('AuthService: Change password response status: ${response.statusCode}');
      log('AuthService: Change password response body: ${response.body}');

      Map<String, dynamic> responseData = jsonDecode(response.body);
      return response.statusCode == 200
          ? MessageModel.fromJson(responseData)
          : MessageModel.withError(responseData);
    } catch (e, stackTrace) {
      log('AuthService: Change password error: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }
}