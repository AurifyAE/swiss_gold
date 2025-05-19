import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/global_variables.dart';
import 'package:swiss_gold/core/utils/colors.dart';


void customSnackBar(
    {required BuildContext context,
    int? duration,
    Color? bgColor,
    double? width,
    required String title,
    Color? titleColor}) {
  final snack = SnackBar(
    width: width??double.infinity,
    padding: const EdgeInsets.all(8),
    duration: Duration(seconds: duration ?? 2),
    // ignore: deprecated_member_use
    backgroundColor: bgColor ?? Colors.black.withOpacity(0.8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    behavior: SnackBarBehavior.floating,
    content: Center(
      child: Text(
        title,
        style: TextStyle(
            color: titleColor ?? UIColor.white,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
    ),
  );
   scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
  scaffoldMessengerKey.currentState!.showSnackBar(snack);
}

void customSnackBarSuccess(
    {required BuildContext context,
    int? duration,
    Color? bgColor,
    required String title,
    Color? titleColor}) {
  final snack = SnackBar(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    duration: Duration(seconds: duration ?? 2),
    backgroundColor: bgColor ?? Colors.green[500],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    behavior: SnackBarBehavior.floating,
    content: Center(
      child: Text(
        title,
        style: TextStyle(
                          fontFamily: 'Familiar',

            color: titleColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
           ),
      ),
    ),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snack);
}
