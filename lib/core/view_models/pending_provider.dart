import 'package:flutter/material.dart';
import '../models/pending_order_model.dart';
import '../services/pending_product_service.dart';
// import '../services/api_service.dart';

class PendingOrdersProvider with ChangeNotifier {
  List<PendingOrder> _pendingOrders = [];
  bool _isLoading = false;
  String? _error;

  List<PendingOrder> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPendingOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getPendingApprovalOrders(userId);
      _pendingOrders = response.data;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _pendingOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}