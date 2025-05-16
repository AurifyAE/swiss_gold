import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class CustomTxtField extends StatelessWidget {
  final String label;
  final bool? isObscure;
  final Widget? suffixIcon;
  final TextEditingController controller;
  const CustomTxtField(
      {super.key, required this.label, this.isObscure, this.suffixIcon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: UIColor.gold,
      controller: controller,
      style: TextStyle(color: UIColor.gold,                fontFamily: 'Familiar',
),
      obscureText: isObscure ?? false,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: UIColor.gold),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: UIColor.gold,
            ),
            borderRadius: BorderRadius.circular(22.sp),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: UIColor.gold,
            ),
            borderRadius: BorderRadius.circular(22.sp),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: UIColor.gold,
            ),
            borderRadius: BorderRadius.circular(22.sp),
          ),
          suffixIcon: suffixIcon),
    );
  }
}
