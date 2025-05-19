import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/utils/endpoint.dart';
import '../models/spot_rate_model.dart';
import 'secrete_key.dart';

class SpotRateService {
  static const String _baseUrl = 'https://api.nova.aurify.ae/user';
  
  // Cache the spot rate data to avoid frequent API calls
  static SpotRateModel? _cachedSpotRate;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Get spot rates for gold from the server
  static Future<SpotRateModel> getSpotRates(String adminId) async {
    // Check if we have a cached spot rate that's still valid
    if (_cachedSpotRate != null && _lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheDuration) {
        log('Using cached spot rate data');
        return _cachedSpotRate!;
      }
    }

    log('Fetching spot rates from API for adminId: $adminId');
    
    try {
      // Use the correct URL format with _baseUrl
      final response = await http.get(
        Uri.parse('$_baseUrl/get-spotrates/$adminId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json',
        },
      );

      log('Spot rate API response status: ${response.statusCode}');
      log('Spot rate API response body: ${response.body}');  // Add this line to debug response

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data.containsKey('info')) {
          log('Successfully retrieved spot rate data');
          
          // Parse and cache the spot rate data
          _cachedSpotRate = SpotRateModel.fromJson(data['info']);
          _lastFetchTime = DateTime.now();
          
          log('Spot rate details - Ask Spread: ${_cachedSpotRate!.goldAskSpread}, Bid Spread: ${_cachedSpotRate!.goldBidSpread}');
          
          return _cachedSpotRate!;
        } else {
          log('API returned success=false or missing info: ${data['message'] ?? "Unknown error"}');
          throw Exception('Failed to load spot rates: ${data['message'] ?? "Unknown error"}');
        }
      } else {
        log('API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load spot rates: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching spot rates: $e');
      // Return default values in case of error
      return SpotRateModel(
        id: '',
        createdBy: '',
        version: 0,
        goldAskSpread: 0.0,
        goldBidSpread: 0.0,
        goldHighMargin: 0.0,
        goldLowMargin: 0.0,
      );
    }
  }

  // Clear the cached spot rate data
  static void clearCache() {
    _cachedSpotRate = null;
    _lastFetchTime = null;
    log('Spot rate cache cleared');
  }
}