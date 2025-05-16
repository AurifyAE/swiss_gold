import 'dart:developer';

import 'package:swiss_gold/core/models/order_model.dart';
import 'package:swiss_gold/core/models/pricing_method_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/order_history.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class OrderHistoryViewModel extends BaseModel {
  OrderModel? _orderModel;
  OrderModel? get orderModel => _orderModel;

  PricingMethodModel? _bankPricingModel;
  PricingMethodModel? get bankPricingModel => _bankPricingModel;

  PricingMethodModel? _cashPricingModel;
  PricingMethodModel? get cashPricingModel => _cashPricingModel;

  ViewState? _moreHistoryState;
  ViewState? get moreHistoryState => _moreHistoryState;

  final List<OrderData> _allOrders = [];
  List<OrderData> get allOrders => _allOrders;

  bool? _isGuest;
  bool? get isGuest => _isGuest;

  // Map for converting filter text to API status parameter
  Map<String, String> statusMapping = {
    'All': '',
    'User Approval Pending': 'User Approval Pending',
    'Processing': 'Processing',
    'Success': 'Success',
    'Rejected': 'Rejected'
  };

  Future<void> getOrderHistory(String page, String status) async {
    setState(ViewState.loading);
    _allOrders.clear();
    
    String apiStatus = statusMapping[status] ?? '';
    log('Fetching orders with status: $apiStatus');
    
    _orderModel = await OrderHistoryService.getOrderHistory(page, apiStatus);
    
    if (_orderModel != null && _orderModel!.data.isNotEmpty) {
      _allOrders.addAll(_orderModel!.data);
      log('Fetched ${_allOrders.length} orders');
    } else {
      log('No orders fetched or null response');
    }
    
    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> getMoreOrderHistory(String page, String status) async {
    setState(ViewState.loadingMore);
    
    String apiStatus = statusMapping[status] ?? '';
    _orderModel = await OrderHistoryService.getOrderHistory(page, apiStatus);
    
    if (_orderModel != null && _orderModel!.data.isNotEmpty) {
      _allOrders.addAll(_orderModel!.data);
      log('Added ${_orderModel!.data.length} more orders. Total: ${_allOrders.length}');
    }
    
    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> getBankPricing(String type) async {
    _bankPricingModel = await OrderHistoryService.getPricing(type);
    notifyListeners();
  }

  Future<void> getCashPricing(String type) async {
    _cashPricingModel = await OrderHistoryService.getPricing(type);
    notifyListeners();
  }

  Future<void> checkGuestMode() async {
    _isGuest = await LocalStorage.getBool('isGuest');
    notifyListeners();
  }
}