// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/utils/widgets/custom_txt_field.dart';
import 'package:swiss_gold/core/view_models/auth_view_model.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _LoginViewState();
}

class _LoginViewState extends State<ChangePasswordView> {
  bool isObscure = true;
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: UIColor.gold,
            )),
        title: Text(
          'Change Password',
          style: TextStyle(color: UIColor.gold, fontSize: 22.sp,                fontFamily: 'Familiar',
),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 34.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                onTap: () {
                  if (mobileController.text.isEmpty ||
                      passController.text.isEmpty) {
                    customSnackBar(
                        context: context, title: 'Email or password is empty');
                  } else {
                    Provider.of<AuthViewModel>(context, listen: false)
                        .changePassword(
                      {
                        "contact": int.parse(mobileController.text),
                        "password": passController.text
                      },
                    ).then((response) {
                      if (response!.success == true) {
                        customSnackBar(
                            context: context,
                            title: response.message.toString());
                        Navigator.pop(context);
                      } else {
                        customSnackBar(
                            context: context,
                            title: response.message.toString());
                      }
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                      color: UIColor.gold,
                      borderRadius: BorderRadius.circular(22.sp)),
                  child: Text(
                    'Confirm',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: UIColor.black, fontSize: 22.sp,                fontFamily: 'Familiar',
),
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
             
              
              
            ],
          ),
        ),
      ),
    );
  }
}
