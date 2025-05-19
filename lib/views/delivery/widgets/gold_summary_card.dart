import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/colors.dart';
import '../../../core/utils/money_format_heper.dart';

class GoldSummaryCard extends StatelessWidget {
  const GoldSummaryCard({
    super.key,
    required this.totalWeight,
  });

  final double totalWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: UIColor.gold),
        color: UIColor.gold.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            'Gold Payment',
            style: TextStyle(
              color: UIColor.gold,
              fontFamily: 'Familiar',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Total Gold: ${formatNumber(totalWeight)} g',
            style: TextStyle(
              color: UIColor.gold,
              fontFamily: 'Familiar',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
