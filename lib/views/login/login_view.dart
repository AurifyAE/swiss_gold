import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/fcm_service.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/utils/widgets/custom_txt_field.dart';
import 'package:swiss_gold/core/view_models/auth_view_model.dart';
import 'package:swiss_gold/views/bottom_nav/bottom_nav.dart';
import '../../core/services/firebase_service.dart';

enum AuthMode { login, register }

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  AuthMode _currentMode = AuthMode.login;
  bool isObscure = true;
  bool isConfirmObscure = true;

  // Controllers
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log('LoginView: Initializing, current mode: $_currentMode');
    if (_currentMode == AuthMode.register) {
      log('LoginView: Fetching categories for registration');
      Provider.of<AuthViewModel>(context, listen: false).fetchCategories();
    }
  }

  @override
  void dispose() {
    log('LoginView: Disposing controllers');
    mobileController.dispose();
    passController.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    log('LoginView: Switching mode to $mode');
    setState(() => _currentMode = mode);
    if (mode == AuthMode.register) {
      log('LoginView: Fetching categories for registration form');
      Provider.of<AuthViewModel>(context, listen: false).fetchCategories();
    }
  }

  bool _validateRegistration() {
    log('LoginView: Validating registration form');
    if (nameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty ||
        passController.text.isEmpty ||
        confirmPassController.text.isEmpty) {
      log('LoginView: Validation failed - empty fields detected');
      customSnackBar(context: context, title: 'Please fill all required fields');
      return false;
    }

    if (passController.text != confirmPassController.text) {
      log('LoginView: Validation failed - passwords do not match');
      customSnackBar(context: context, title: 'Passwords do not match');
      return false;
    }

    if (passController.text.length < 6) {
      log('LoginView: Validation failed - password too short');
      customSnackBar(context: context, title: 'Password must be at least 6 characters');
      return false;
    }

    if (Provider.of<AuthViewModel>(context, listen: false).selectedCategoryId == null) {
      log('LoginView: Validation failed - no category selected');
      customSnackBar(context: context, title: 'Please select a category');
      return false;
    }

    log('LoginView: Registration form validation passed');
    return true;
  }

  void _showCategoryBottomSheet(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    log('LoginView: Opening category bottom sheet with ${authViewModel.categories.length} categories');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: UIColor.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: UIColor.gold.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    color: UIColor.gold,
                    fontSize: 18.sp,
                    fontFamily: 'Familiar',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Categories List
              Flexible(
                child: Consumer<AuthViewModel>(
                  builder: (ctx, authVM, _) {
                    if (authVM.categories.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.h),
                          child: Text(
                            'No categories available',
                            style: TextStyle(
                              color: UIColor.gold.withOpacity(0.5),
                              fontSize: 14.sp,
                              fontFamily: 'Familiar',
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: authVM.categories.length,
                      itemBuilder: (context, index) {
                        final category = authVM.categories[index];
                        final isSelected = authVM.selectedCategoryId == category['_id'];
                        
                        return InkWell(
                          onTap: () {
                            log('LoginView: Category selected: ${category['_id']}');
                            Provider.of<AuthViewModel>(context, listen: false)
                                .setSelectedCategory(category['_id']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? UIColor.gold.withOpacity(0.15) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                // Category name
                                Expanded(
                                  child: Text(
                                    category['name'],
                                    style: TextStyle(
                                      color: UIColor.gold,
                                      fontSize: 15.sp,
                                      fontFamily: 'Familiar',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                
                                // Check icon
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: UIColor.gold,
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final selectedCategory = authViewModel.categories.firstWhere(
          (cat) => cat['_id'] == authViewModel.selectedCategoryId,
          orElse: () => {'name': ''},
        );
        
        return GestureDetector(
          onTap: () => _showCategoryBottomSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.r), 
              border: Border.all(
                color: UIColor.gold,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCategory['name'].isEmpty
                        ? 'Category'
                        : selectedCategory['name'],
                    style: TextStyle(
                      color: UIColor.gold,
                      fontSize: 16.sp,
                      fontFamily: 'Familiar',
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: UIColor.gold,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    String title = _currentMode == AuthMode.login ? 'Hello Again!' : 'Create Account';
    String subtitle = _currentMode == AuthMode.login 
        ? 'Welcome back, You have been missed.'
        : 'Join us and start your journey today.'; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            title,
            key: ValueKey(title),
            style: TextStyle(
              color: UIColor.gold,
              fontSize: 28.sp,
              fontFamily: 'Familiar',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            subtitle,
            key: ValueKey(subtitle),
            style: TextStyle(
              color: UIColor.gold.withOpacity(0.8),
              fontSize: 14.sp,
              fontFamily: 'Familiar',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTxtField(
          label: 'Mobile',
          controller: mobileController,
        ),
        SizedBox(height: 15.h),
        CustomTxtField(
          controller: passController,
          label: 'Password',
          isObscure: isObscure,
          suffixIcon: IconButton(
            onPressed: () {
              log('LoginView: Toggling password visibility');
              setState(() => isObscure = !isObscure);
            },
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: UIColor.gold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Column(
      children: [
        CustomTxtField(label: 'Full Name', controller: nameController),
        SizedBox(height: 15.h),
        CustomTxtField(label: 'Mobile Number', controller: mobileController),
        SizedBox(height: 15.h),
        CustomTxtField(label: 'Email Address', controller: emailController),
        SizedBox(height: 15.h),
        CustomTxtField(label: 'Address', controller: addressController),
        SizedBox(height: 15.h),
        _buildCategorySelector(context),
        SizedBox(height: 15.h),
        CustomTxtField(
          controller: passController,
          label: 'Password',
          isObscure: isObscure,
          suffixIcon: IconButton(
            onPressed: () {
              log('LoginView: Toggling password visibility');
              setState(() => isObscure = !isObscure);
            },
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: UIColor.gold,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        CustomTxtField(
          controller: confirmPassController,
          label: 'Confirm Password',
          isObscure: isConfirmObscure,
          suffixIcon: IconButton(
            onPressed: () {
              log('LoginView: Toggling confirm password visibility');
              setState(() => isConfirmObscure = !isConfirmObscure);
            },
            icon: Icon(
              isConfirmObscure ? Icons.visibility_off : Icons.visibility,
              color: UIColor.gold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    log('LoginView: Handling login');
    if (mobileController.text.isEmpty || passController.text.isEmpty) {
      log('LoginView: Login validation failed - empty mobile or password');
      customSnackBar(context: context, title: 'Mobile or password is empty');
      return;
    }

    final token = await FcmService.getToken();
    log('LoginView: FCM Token retrieved: $token');

    final payload = {
      "contact": int.parse(mobileController.text),
      "password": passController.text,
      'token': token,
    };
    log('LoginView: Login payload: $payload');

    final response = await Provider.of<AuthViewModel>(context, listen: false).login(payload);
    log('LoginView: Login response received: success=${response?.success}, message=${response?.message}, userId=${response?.userId}');

    if (response == null) {
      log('LoginView: Login response is null');
      customSnackBar(context: context, title: 'Login failed. Please try again.');
      return;
    }

    if (response.success) {
      log('LoginView: Login successful, userId: ${response.userId}');
      await LocalStorage.setBool('isGuest', false);
      log('LoginView: Set isGuest to false');

      FcmService.requestPermission();
      log('LoginView: Requested FCM permission');

      final userId = response.userId;
      if (userId.isNotEmpty && token != null) {
        try {
          log('LoginView: Saving FCM token for user: $userId');
          await FirebaseService().saveUserFcmToken(userId, token);
          log('LoginView: FCM token saved to Firebase');
        } catch (e, stackTrace) {
          log('LoginView: Failed to save FCM token: ${e.toString()}', stackTrace: stackTrace);
        }
      }

      customSnackBar(
        context: context,
        title: response.message,
        bgColor: UIColor.gold,
        width: 130.w,
      );

      log('LoginView: Navigating to BottomNav');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
        (route) => false,
      );
    } else {
      log('LoginView: Login failed with message: ${response.message}');
      customSnackBar(context: context, title: response.message);
    }
  }

  Future<void> _handleRegistration() async {
    log('LoginView: Handling registration');
    if (!_validateRegistration()) {
      log('LoginView: Registration validation failed');
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final token = await FcmService.getToken();
    log('LoginView: FCM Token retrieved for registration: $token');

    final payload = {
      "name": nameController.text,
      "email": emailController.text,
      "categoryId": authViewModel.selectedCategoryId,
      "address": addressController.text,
      "contact": mobileController.text,
      "password": passController.text,
      "token": token,
    };
    log('LoginView: Registration payload: $payload');

    final response = await authViewModel.register(payload);
    log('LoginView: Registration response received: success=${response?.success}, message=${response?.message}, userId=${response?.userId}');

    if (response == null) {
      log('LoginView: Registration response is null');
      customSnackBar(context: context, title: 'Registration failed. Please try again.');
      return;
    }

    if (response.success) {
      log('LoginView: Registration successful, userId: ${response.userId}');
      await LocalStorage.setBool('isGuest', false);
      log('LoginView: Set isGuest to false');

      FcmService.requestPermission();
      log('LoginView: Requested FCM permission');

      final userId = response.userId;
      if (userId.isNotEmpty && token != null) {
        try {
          log('LoginView: Saving FCM token for user: $userId');
          await FirebaseService().saveUserFcmToken(userId, token);
          log('LoginView: FCM token saved to Firebase');
        } catch (e, stackTrace) {
          log('LoginView: Failed to save FCM token: ${e.toString()}', stackTrace: stackTrace);
        }
      }

      customSnackBar(
        context: context,
        title: response.message,
        bgColor: UIColor.gold,
        width: 200.w,  
      );

      // Clear form fields
      log('LoginView: Clearing registration form fields');
      nameController.clear();
      emailController.clear();
      addressController.clear();
      mobileController.clear();
      passController.clear();
      confirmPassController.clear();

      // Switch to login mode
      log('LoginView: Switching to login mode after successful registration');
      _switchMode(AuthMode.login);
    } else {
      log('LoginView: Registration failed with message: ${response.message}');
      customSnackBar(context: context, title: response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    log('LoginView: Building UI, current mode: $_currentMode');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchMode(AuthMode.login),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentMode == AuthMode.login
                                  ? UIColor.gold
                                  : Colors.transparent,
                              width: 2.w,
                            ),
                          ),
                        ),
                        child: Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _currentMode == AuthMode.login
                                ? UIColor.gold
                                : UIColor.gold.withOpacity(0.6),
                            fontSize: 16.sp,
                            fontFamily: 'Familiar',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchMode(AuthMode.register),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentMode == AuthMode.register
                                  ? UIColor.gold
                                  : Colors.transparent,
                              width: 2.w,
                            ),
                          ),
                        ),
                        child: Text(
                          'Register',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _currentMode == AuthMode.register
                                ? UIColor.gold
                                : UIColor.gold.withOpacity(0.6),
                            fontSize: 16.sp,
                            fontFamily: 'Familiar',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _currentMode == AuthMode.login
                  ? _buildLoginForm()
                  : _buildRegistrationForm(context),
              SizedBox(height: 30.h),
              GestureDetector(
                onTap: () {
                  log('LoginView: Submit button tapped, mode: $_currentMode');
                  _currentMode == AuthMode.login ? _handleLogin() : _handleRegistration();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: UIColor.gold,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: UIColor.gold.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentMode == AuthMode.login ? 'Login' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: UIColor.black,
                      fontSize: 18.sp,
                      fontFamily: 'Familiar',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_currentMode == AuthMode.login) ...[
                SizedBox(height: 15.h),
                CustomOutlinedBtn(
                  borderRadius: 22.r,
                  borderColor: UIColor.gold,
                  padH: 12.w,
                  padV: 12.h,
                  btnText: 'Continue as guest',
                  btnTextColor: UIColor.gold,
                  fontSize: 18.sp,
                  onTapped: () {
                    log('LoginView: Guest login button tapped');
                    LocalStorage.setBool('isGuest', true).then((_) {
                      LocalStorage.setString({'userName': 'Guest'});
                      log('LoginView: Navigating to BottomNav for guest user');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNav()),
                        (route) => false,
                      );
                    });
                  },
                ),
              ],
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}