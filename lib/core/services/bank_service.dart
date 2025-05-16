import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:fxg_app/app/core/constants/constants.dart';
import 'package:http/http.dart' as http;

import '../models/bank_model.dart';
import 'secrete_key.dart';

class BankProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  BankResponse? _bankResponse;
  bool _isRequestingAdmin = false;
  bool _requestSent = false;
  String _requestMessage = '';
  
  // URL for the API
  final String apiUrl = 'https://api.nova.aurify.ae/user/get-banks/67f37dfe4831e0eb637d09f1';
  final String adminRequestUrl = 'https://api.nova.aurify.ae/user/request-admin';
  final String adminId = '67f37dfe4831e0eb637d09f1'; // Replace with actual admin ID if different
  
  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  BankResponse? get bankResponse => _bankResponse;
  bool get isRequestingAdmin => _isRequestingAdmin;
  bool get requestSent => _requestSent;
  String get requestMessage => _requestMessage;
  
  // Constructor that fetches data when initialized
  BankProvider() {
    fetchBankDetails();
  }
  
  // Reset request sent flag (to prevent showing snackbar multiple times)
  void resetRequestSent() {
    _requestSent = false;
    notifyListeners();
  }
  
  Future<void> fetchBankDetails() async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _requestSent = false;
      notifyListeners();
      
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'X-Secret-Key': secreteKey,
        'Content-Type': 'application/json'
      },);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _bankResponse = BankResponse.fromJson(jsonData);
      } else {
        _hasError = true;
        _errorMessage = 'Failed to load bank details. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error fetching bank details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> requestAdminToAddBankDetails() async {
    try {
      _isRequestingAdmin = true;
      _requestSent = false;
      _requestMessage = '';
      notifyListeners();
      
      // Add a small delay to show loading indicator
      await Future.delayed(const Duration(milliseconds: 500));
      
      final response = await http.post(
        Uri.parse('$adminRequestUrl/$adminId'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'request': 'Please add bank details to my account'
        })
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _requestSent = true;
        _requestMessage = 'Request sent successfully to admin';
        notifyListeners();
        return true;
      } else {
        _requestMessage = 'Failed to send request. Status code: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _requestMessage = 'Error sending request: $e';
      notifyListeners();
      return false;
    } finally {
      _isRequestingAdmin = false;
      notifyListeners();
    }
  }
}