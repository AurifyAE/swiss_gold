import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';
import 'package:swiss_gold/core/services/local_storage.dart'; // Make sure to import local storage

class TransactionService {
  // No longer requiring UserModel in constructor
  TransactionService() {
    log('TransactionService initialized');
  }
  
  // Helper method to get userId from local storage
  Future<String> _getUserId() async {
    final userId = await LocalStorage.getString('userId') ?? '';
    if (userId.isEmpty) {
      log('Warning: User ID from local storage is empty');
    }
    return userId;
  }

  Future<TransactionResponse?> fetchTransactions({int page = 1, int limit = 10}) async {
    final userId = await _getUserId();
    if (userId.isEmpty) {
      log('Cannot fetch transactions: User ID is empty');
      return null;
    }
    
    try {
      log('Fetching transactions for user: $userId, page: $page');
      
      final Uri uri = Uri.parse('https://api.nova.aurify.ae/user/fetch-transaction/$userId');
        // .replace(queryParameters: {
        //   'page': '$page',
        //   'limit': '$limit'
        // });
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        log('Transaction response received successfully');
        return TransactionResponse.fromJson(decodedResponse);
      } else {
        log('Failed to fetch transactions: ${response.statusCode}');
        log('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error fetching transactions: $e');
      return null;
    }
  }
  
  // Method to fetch a specific transaction by ID
  Future<Transaction?> fetchTransactionById(String transactionId) async {
    final userId = await _getUserId();
    if (userId.isEmpty || transactionId.isEmpty) {
      log('Cannot fetch transaction: User ID or Transaction ID is empty');
      return null;
    }
    
    try {
      log('Fetching transaction details for ID: $transactionId');
      
      final response = await http.get(
        Uri.parse('$newBaseUrl/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] != null) {
          return Transaction.fromJson(decodedResponse['data']);
        }
        return null;
      } else {
        log('Failed to fetch transaction details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching transaction details: $e');
      return null;
    }
  }
  
  // Method to fetch user balance
  Future<BalanceInfo?> fetchBalance() async {
    final userId = await _getUserId();
    if (userId.isEmpty) {
      log('Cannot fetch balance: User ID is empty');
      return null;
    }
    
    try {
      log('Fetching balance for user: $userId');
      
      final response = await http.get(
        Uri.parse('$newBaseUrl/user-balance/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] != null) {
          return BalanceInfo.fromJson(decodedResponse['data']);
        }
        return null;
      } else {
        log('Failed to fetch balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching balance: $e');
      return null;
    }
  }
  
  // Method to get transaction summary
  Future<Summary?> fetchTransactionSummary() async {
    final userId = await _getUserId();
    if (userId.isEmpty) {
      log('Cannot fetch transaction summary: User ID is empty');
      return null;
    }
    
    try {
      log('Fetching transaction summary for user: $userId');
      
      final response = await http.get(
        Uri.parse('$newBaseUrl/transaction-summary/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] != null) {
          return Summary.fromJson(decodedResponse['data']);
        }
        return null;
      } else {
        log('Failed to fetch transaction summary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching transaction summary: $e');
      return null;
    }
  }
}