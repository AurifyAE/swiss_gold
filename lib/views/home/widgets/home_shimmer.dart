import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: Duration(milliseconds: 1000),
      baseColor: UIColor.gold, // Gold base color
      highlightColor: Color(0xFFFFE5B4), // Lighter golden highlight color
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w,vertical: 12.h),
        width: double.infinity,
        height: 220.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: UIColor.gold, // Set background color to baseColor
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
