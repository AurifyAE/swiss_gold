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

static Future<UserModel?> login(Map<String, dynamic> payload) async {
  try {
    var response = await client.post(
      Uri.parse(loginUrl),
      headers: {
        'X-Secret-Key': secreteKey,
        'Content-Type': 'application/json'
      },
      body: jsonEncode(payload),
    );

    Map<String, dynamic> responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      // Store user data in local storage
      if (responseData.containsKey('_id') || 
          responseData.containsKey('userId') ||
          (responseData.containsKey('info') && responseData['info'].containsKey('_id'))) {
        
        String userId = '';
        if (responseData.containsKey('_id')) {
          userId = responseData['_id'];
        } else if (responseData.containsKey('userId')) {
          userId = responseData['userId'];
        } else if (responseData.containsKey('info')) {
          userId = responseData['info']['_id'];
        }
        
        await LocalStorage.setString({'userId': userId});
        
        // Store other user details if available
        if (responseData.containsKey('userDetails')) {
          var userDetails = responseData['userDetails'];
          await Future.wait([
            LocalStorage.setString({'userName': userDetails['name'] ?? 'User'}),
            LocalStorage.setString({'mobile': (userDetails['contact'] ?? '').toString()}),
            if (userDetails.containsKey('categoryId'))
              LocalStorage.setString({'categoryId': userDetails['categoryId'] ?? ''}),
            if (userDetails.containsKey('categoryName'))
              LocalStorage.setString({'category': userDetails['categoryName'] ?? ''}),
          ]);
        } else if (responseData.containsKey('info')) {
          var info = responseData['info'];
          await Future.wait([
            LocalStorage.setString({'userName': info['userName'] ?? info['companyName'] ?? 'User'}),
            LocalStorage.setString({'mobile': (info['contact'] ?? '').toString()}),
          ]);
        }
      }

      return UserModel.fromJson(responseData);
    } else {
      return UserModel.withError(responseData);
    }
  } catch (e) {
    log('Login service error: ${e.toString()}');
    return UserModel.withError({
      'message': 'An error occurred during login',
      'success': false
    });
  }
}

  static Future<MessageModel?> changePassword(
      Map<String, dynamic> payload) async {
    try {
      var response = await client.put(
        Uri.parse(changePassUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload), // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return MessageModel.withError(responseData);
      }
    } catch (e) {
      return null;
    }
  }
}
