import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class ContactCard extends StatelessWidget {
  final String icon;
  final String title;
  final Function()? onTap;
  const ContactCard(
      {super.key, required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
            border: Border.all(color: UIColor.gold),
            borderRadius: BorderRadius.circular(12.sp)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 30.w,
              height: 30.h,
            ),
            SizedBox(height: 5.h,),
            Text(
              title,
              style: TextStyle(color: UIColor.gold, fontSize: 12.sp,                fontFamily: 'Familiar',
),
            )
          ],
        ),
      ),
    );
  }
}
