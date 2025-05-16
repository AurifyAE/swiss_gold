// ignore_for_file: use_build_context_synchronously

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

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isObscure = true;
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 34.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello Again!',
                style: TextStyle(
                  color: UIColor.gold,
                  fontSize: 28.sp,
                  fontFamily: 'Familiar',
                ),
              ),
              Text(
                'Welcome back , You have been missed.',
                style: TextStyle(
                  color: UIColor.gold,
                  fontSize: 14.sp,
                  fontFamily: 'Familiar',
                ),
              ),
              SizedBox(
                height: 48.h,
              ),
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
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: UIColor.gold,
                    )),
              ),
              SizedBox(height: 30.h),
              GestureDetector(
                onTap: () async {
                  if (mobileController.text.isEmpty ||
                      passController.text.isEmpty) {
                    customSnackBar(
                        context: context, title: 'Email or password is empty');
                  } else {
                    final token = await FcmService.getToken();
                    log(token.toString());

                    log('📲 FCM Token: $token');


                    // Inside your onTap method in LoginView.dart
Provider.of<AuthViewModel>(context, listen: false)
    .login({
      "contact": int.parse(mobileController.text),
      "password": passController.text,
      'token': token,
    })
    .then((response) async {
      if (response == null) {
        customSnackBar(
          context: context, 
          title: 'Login failed. Please try again.'
        );
        return;
      }
      
      if (response.success) {
        LocalStorage.setBool('isGuest', false);
        FcmService.requestPermission();
        
        final userId = response.userId;
        if (userId.isNotEmpty) {
          // Save userId to local storage for future use
          await LocalStorage.setString({'userId': userId});
          
          // Add FCM token to Firebase Realtime Database
          if (token != null) {
            try {
              await FirebaseService().saveUserFcmToken(userId, token);
              log('FCM token saved to Firebase for user: $userId');
            } catch (e) {
              log('Failed to save FCM token: $e');
              // Optionally show a snackbar but don't block login
            }
          }
        }
        
        customSnackBar(
          context: context,
          title: response.message,
          bgColor: UIColor.gold,
          width: 130.w
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
          (route) => false
        );
      } else {
        customSnackBar(context: context, title: response.message);
      }
    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                      color: UIColor.gold,
                      borderRadius: BorderRadius.circular(22.sp)),
                  child: Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: UIColor.black,
                      fontSize: 18.sp,
                      fontFamily: 'Familiar',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              CustomOutlinedBtn(
                borderRadius: 22.sp,
                borderColor: UIColor.gold,
                padH: 12.w,
                padV: 12.h,
                btnText: 'Continue as guest',
                btnTextColor: UIColor.gold,
                fontSize: 18.sp,
                onTapped: () {
                  LocalStorage.setBool('isGuest', true).then((_) {
                    LocalStorage.setString({'userName': 'Guest'});
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNav()),
                        (route) => false);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}