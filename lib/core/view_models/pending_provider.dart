import 'package:flutter/material.dart';
import '../models/pending_order_model.dart';
import '../services/pending_product_service.dart'; // Changed from pending_product_service.dart

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

  Future<bool> approveOrderItem({
    required String orderId,
    required String itemId,
    required String userId,
    required int quantity,
    required double fixedPrice,
    required double productWeight,
  }) async {
    try {
      final success = await ApiService.approveOrderItem(
        orderId: orderId,
        itemId: itemId,
        userId: userId,
        quantity: quantity,
        fixedPrice: fixedPrice,
        productWeight: productWeight,
      );
      
      if (success) {
        // Refresh the pending orders list instead of manually removing
        await fetchPendingOrders(userId);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectOrderItem({
    required String orderId,
    required String itemId,
    required String userId,
    required String rejectionReason,
  }) async {
    try {
      final success = await ApiService.rejectOrderItem(
        orderId: orderId,
        itemId: itemId,
        userId: userId,
        rejectionReason: rejectionReason,
      );
      
      if (success) {
        // Refresh the pending orders list instead of manually removing
        await fetchPendingOrders(userId);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}