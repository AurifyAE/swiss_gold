import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swiss_gold/core/models/cart_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/cart_service.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';
import 'package:swiss_gold/views/delivery/delivery_view.dart';

class CartViewModel extends BaseModel {
  bool? _isGuest;
  bool? get isGuest => _isGuest;

  CartModel? _cartModel;
  CartModel? get cartModel => _cartModel;

  ViewState? _quantityState;
  ViewState? get quantityState => _quantityState;

  final List<CartItem> _cartItemList = [];
  List<CartItem> get cartList => _cartItemList;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  Future<void> getCart() async {
    setState(ViewState.loading);
    _cartModel = await CartService.getCart();
    _cartItemList.clear();

    if (_cartModel != null) {
      for (var cartItem in cartModel!.data) {
        for (var item in cartItem.items) {
          _cartItemList.add(item);
        }
      }
    }

    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> updatePrice() async {
    _cartModel = await CartService.getCart();
    _cartItemList.clear();

    if (_cartModel != null) {
      for (var cartItem in cartModel!.data) {
        for (var item in cartItem.items) {
          _cartItemList.add(item);
        }
      }
    }

    notifyListeners();
  }

  Future<MessageModel?> updateQuantityFromHome(String pId,
      Map<String, dynamic> payload) async {
    log('payload from view model $payload');
    setState(ViewState.loading);
    _messageModel = await CartService.updateQuantityFromHome(pId, payload);

    setState(ViewState.idle);
    notifyListeners();

    return _messageModel;
  }

  Future<MessageModel?> updateCartQuantity(String productId, int quantity) async {
    setState(ViewState.loading);
    _messageModel = await CartService.updateCartQuantity(productId, quantity);
    
    // Fixed: Check both that _messageModel isn't null AND success is true
    if (_messageModel != null && _messageModel!.success == true) {
      // Update local cart item if it exists
      final itemIndex = _cartItemList.indexWhere((item) => item.productId == productId);
      if (itemIndex != -1) {
        _cartItemList[itemIndex].quantity = quantity;
      }
    }
    
    setState(ViewState.idle);
    notifyListeners();
    
    return _messageModel;
  }

  Future<void> checkGuestMode() async {
    _isGuest = await LocalStorage.getBool('isGuest');
    notifyListeners();
  }

  Future<void> confirmQuantity(bool action) async {
    CartService.confirmQuantity({'action': action});
  }

  Future<MessageModel?> deleteFromCart(Map<String, dynamic> payload) async {
    _messageModel = await CartService.deleteFromCart(payload);
    notifyListeners();
    return _messageModel;
  }

  Future<MessageModel?> incrementQuantity(Map<String, dynamic> payload, {int? index}) async {
    _quantityState = ViewState.loading;
    notifyListeners();
    _messageModel = await CartService.incrementQuantity(payload);
    
    // Fixed: Check both that _messageModel isn't null AND success is true
    if (_messageModel != null && _messageModel!.success == true && index != null) {
      if (index < _cartItemList.length) {
        _cartItemList[index].quantity = _cartItemList[index].quantity + 1;
      }
    }

    _quantityState = ViewState.idle;
    notifyListeners();
    return _messageModel;
  }

  Future<MessageModel?> decrementQuantity(Map<String, dynamic> payload, {int? index}) async {
    _quantityState = ViewState.loading;
    notifyListeners();
    _messageModel = await CartService.decrementQuantity(payload);
    
    // Fixed: Check both that _messageModel isn't null AND success is true
    if (_messageModel != null && _messageModel!.success == true && index != null) {
      if (index < _cartItemList.length) {
        _cartItemList[index].quantity = _cartItemList[index].quantity - 1;
      }
    }
    
    _quantityState = ViewState.idle;
    notifyListeners();
    return _messageModel;
  }

  // Added the missing clearCart method
  Future<MessageModel?> clearCart() async {
    setState(ViewState.loading);
    try {
      _messageModel = await CartService.clearCart();
      
      if (_messageModel != null && _messageModel!.success == true) {
        _cartItemList.clear();
        log('Cart cleared successfully');
      } else {
        log('Failed to clear cart: ${_messageModel?.message ?? "Unknown error"}');
      }
    } catch (e) {
      log('Error clearing cart: ${e.toString()}');
      _messageModel = MessageModel(success: false, message: e.toString());
    }
    
    setState(ViewState.idle);
    notifyListeners();
    return _messageModel;
  }

  void navigateToDeliveryPage(BuildContext context, Map<String, dynamic> bookingData, DateTime deliveryDate, String paymentMethod) {
    Map<String, dynamic> orderData = {
      "bookingData": bookingData,
      "paymentMethod": paymentMethod,
      "deliveryDate": deliveryDate.toString().split(' ')[0]
    };

    navigateWithAnimationTo(
      context,
      DeliveryDetailsView(
        orderData: orderData,
        onConfirm: (deliveryDetails) {
          // Process the order with delivery details
          final Map<String, dynamic> finalPayload = {
            ...orderData,
            ...deliveryDetails,
          };
          
          // Handle order processing logic
          log('Processing order with data: $finalPayload');
        },
      ),
      0,
      1,
    );
  }
}