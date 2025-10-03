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
  bool _isGuest = false;
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId = 'default';

  bool get isGuest => _isGuest;
  UserModel? get userModel => _userModel;
  List<Map<String, dynamic>> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;

  Future<UserModel?> login(Map<String, dynamic> payload) async {
    log('AuthViewModel: Initiating login with payload: $payload');
    setState(ViewState.loading);
    try {
      _userModel = await AuthService.login(payload);
      log('AuthViewModel: Login result - success: ${_userModel?.success}, message: ${_userModel?.message}, userId: ${_userModel?.userId}');
    } catch (e, stackTrace) {
      log('AuthViewModel: Login error: ${e.toString()}', stackTrace: stackTrace);
      _userModel = UserModel.withError({
        'message': 'An error occurred during login',
        'success': false
      });
    }
    setState(ViewState.idle);
    log('AuthViewModel: Login state changed to idle');
    return _userModel;
  }

  Future<UserModel?> register(Map<String, dynamic> payload) async {
    log('AuthViewModel: Initiating registration with payload: $payload');
    setState(ViewState.loading);
    try {
      _userModel = await AuthService.register(payload);
      log('AuthViewModel: Registration result - success: ${_userModel?.success}, message: ${_userModel?.message}, userId: ${_userModel?.userId}');
    } catch (e, stackTrace) {
      log('AuthViewModel: Registration error: ${e.toString()}', stackTrace: stackTrace);
      _userModel = UserModel.withError({
        'message': 'An error occurred during registration',
        'success': false
      });
    }
    setState(ViewState.idle);
    log('AuthViewModel: Registration state changed to idle');
    return _userModel;
  }

  Future<void> fetchCategories() async {
    log('AuthViewModel: Fetching categories');
    setState(ViewState.loading);
    try {
      final categories = await AuthService.getCategories();
      if (categories != null) {
        _categories = categories;
        _selectedCategoryId = 'default';
        log('AuthViewModel: Fetched ${_categories.length} categories, selectedCategoryId: $_selectedCategoryId');
      } else {
        log('AuthViewModel: No categories fetched');
        _categories = [];
        _selectedCategoryId = 'default';
      }
    } catch (e, stackTrace) {
      log('AuthViewModel: Fetch categories error: ${e.toString()}', stackTrace: stackTrace);
      _categories = [];
      _selectedCategoryId = 'default';
    }
    setState(ViewState.idle);
    log('AuthViewModel: Category fetch state changed to idle');
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    log('AuthViewModel: Setting selected category to: $categoryId');
    _selectedCategoryId = categoryId ?? 'default';
    notifyListeners();
  }

  Future<MessageModel?> changePassword(Map<String, dynamic> payload) async {
    log('AuthViewModel: Initiating change password with payload: $payload');
    setState(ViewState.loading);
    try {
      _messageModel = await AuthService.changePassword(payload);
    } catch (e, stackTrace) {
      log('AuthViewModel: Change password error: ${e.toString()}', stackTrace: stackTrace);
    }
    setState(ViewState.idle);
    log('AuthViewModel: Change password state changed to idle');
    return _messageModel;
  }

  Future<void> checkGuestMode() async {
    log('AuthViewModel: Checking guest mode');
    try {
      _isGuest = await LocalStorage.getBool('isGuest') ?? false;
      log('AuthViewModel: Guest mode status: $_isGuest');
    } catch (e, stackTrace) {
      log('AuthViewModel: Error checking guest mode: ${e.toString()}', stackTrace: stackTrace);
      _isGuest = false; 
    }
    notifyListeners();
  }

  void logout() {
    log('AuthViewModel: Logging out user');
    _userModel = null;
    _messageModel = null;
    _isGuest = false;
    _categories = [];
    _selectedCategoryId = 'default';
    notifyListeners();
    log('AuthViewModel: Logout completed');
  }
}