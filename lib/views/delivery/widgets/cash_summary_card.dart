import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/colors.dart';
import '../../../core/utils/money_format_heper.dart';

class CashSummaryCard extends StatelessWidget {
  const CashSummaryCard({
    super.key,
    required this.bidPrice,
    required this.totalAmount,
  });

  final double bidPrice;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: UIColor.gold),
        // ignore: deprecated_member_use
        color: UIColor.gold.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            'Cash Payment',
            style: TextStyle(
              color: UIColor.gold,
              fontFamily: 'Familiar',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Live rate: ${bidPrice > 0 ? formatNumber(bidPrice) : "2,592.97"}',
            style: TextStyle(
              color: UIColor.gold,
              fontFamily: 'Familiar',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Total Amount: AED ${formatNumber(totalAmount)}',
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

