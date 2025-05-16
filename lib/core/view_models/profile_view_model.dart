import 'dart:developer';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class ProfileViewModel extends BaseModel {
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  Future<void> getProfile() async {
    setState(ViewState.loading);

    try {
      
      final userName = await LocalStorage.getString('userName') ?? "Guest";
      String category = await LocalStorage.getString('category') ?? "";
      String mobile = await LocalStorage.getString('mobile') ?? "";
      String location = await LocalStorage.getString('location') ?? "";

      _userModel = UserModel(
        category: category,
        userName: userName,
        mobile: mobile,
        location: location,
      );

    } catch (e) {
      log('Error fetching profile: $e');
    } finally {
      setState(ViewState.idle);
      notifyListeners();
    }
  }

  
}

class UserModel {
  final String userName;
  final String category;
  final String mobile;
  final String location;

  UserModel({
    required this.category,
    required this.userName,
    required this.mobile,
    required this.location,
  });

  @override
  String toString() {
    return 'UserModel(userName: $userName, category: $category, mobile: $mobile, location: $location)';
  }
}
