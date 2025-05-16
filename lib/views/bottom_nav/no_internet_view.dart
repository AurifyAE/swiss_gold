import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: UIColor.gold),
            SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: TextStyle(
                color: UIColor.gold,
                                fontFamily: 'Familiar',

                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                color: UIColor.gold,
                                fontFamily: 'Familiar',

                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.h),
            CustomOutlinedBtn(
              borderRadius: 30.sp,
              borderColor: UIColor.gold,
              padH: 10.w,
              padV: 15.h,
              btnText: 'Retry',
              
              fontSize: 18.sp,
              btnTextColor: UIColor.gold,
              width: 200.w,
              onTapped: onRetry
            )
          ],
        ),
      ),
    );
  }
}
