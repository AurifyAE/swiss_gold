import 'dart:developer';

import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/models/user_model.dart';
import 'package:swiss_gold/core/services/auth_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

import '../services/local_storage.dart';

class AuthViewModel extends BaseModel {
  UserModel? _userModel;

  MessageModel? _messageModel;

  Future<UserModel?> login(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    try {
      _userModel = await AuthService.login(payload);
      // Only log the ID if _userModel is not null
      if (_userModel != null) {
      }
    } catch (e) {
      log('Login error: ${e.toString()}');
    }
    setState(ViewState.idle);
    return _userModel;
  }

  Future<MessageModel?> changePassword(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    _messageModel = await AuthService.changePassword(payload);

    setState(ViewState.idle);
    return _messageModel;
  }

  bool _isGuest = false;

  bool get isGuest => _isGuest;

  void logout() {
  _userModel = null;
  _messageModel = null;
  _isGuest = false;
  notifyListeners();
}


 Future<void> checkGuestMode() async {
    try {
      _isGuest = await LocalStorage.getBool('isGuest') ?? false;
      log('Guest mode: $_isGuest');
    } catch (e) {
      log('Error checking guest mode: ${e.toString()}');
      _isGuest = false;
    }
    notifyListeners();
  }
}
