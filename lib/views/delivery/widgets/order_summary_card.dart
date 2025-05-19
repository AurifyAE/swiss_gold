import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/colors.dart';
import '../../../core/utils/money_format_heper.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.isGoldPayment,
    required this.totalWeight,
    required this.totalAmount,
  });

  final bool isGoldPayment;
  final double totalWeight;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Order Summary',
          style: TextStyle(
            color: UIColor.gold,
            fontFamily: 'Familiar',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        if (isGoldPayment) ...[
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Gold Payment:',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${formatNumber(totalWeight)} g',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
        if (!isGoldPayment) ...[
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Cash Payment:',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'AED ${formatNumber(totalAmount)}',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
