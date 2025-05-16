import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/admin_profile_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class ProfileService {
  static final client = http.Client();

  static Future<CompanyProfileModel?> fetchCompanyProfile() async {
  try {
    final adminId = '67f37dfe4831e0eb637d09f1'; // or 'adminId' if that's the key
    final url = 'https://api.nova.aurify.ae/user/get-profile/$adminId';

    var response = await client.get(
      Uri.parse(url),
      headers: {
        'X-Secret-Key': secreteKey,
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return CompanyProfileModel.fromJson(responseData);
    } else {
      return null;
    }
  } catch (e) {
    log('Error fetching profile: $e');
    return null;
  }
}


  static Future<String?> fetchCompanyAd() async {
    try {
      var response = await client.get(
        Uri.parse(getVideoBannerUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log(responseData['banners'][0].toString());

        return responseData['banners'][0];
      } else {
         
        
        return 'https://videos.pexels.com/video-files/8516369/8516369-uhd_1440_2560_30fps.mp4';
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<MessageModel?> changePassword(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = changePassUrl.replaceFirst('{userId}', id.toString());
      var response = await client.post(Uri.parse(url),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload));

      log(payload.toString());
      log(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log(responseData.toString());
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log(responseData.toString());
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
