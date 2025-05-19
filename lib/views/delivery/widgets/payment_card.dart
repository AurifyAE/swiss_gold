
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/colors.dart';
import '../../../core/utils/money_format_heper.dart';
import '../delivery_view.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.widget,
    required this.isGoldPayment,
    required this.totalAmount,
  });

  final DeliveryDetailsView widget;
  final bool isGoldPayment;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: UIColor.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method:',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 16.sp,
                ),
              ),
              Text(
                widget.orderData["paymentMethod"] ?? 'Not specified',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Date:',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 16.sp,
                ),
              ),
              Text(
                widget.orderData["deliveryDate"] ?? 'Not specified',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items:',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 16.sp,
                ),
              ),
              Text(
                '${(widget.orderData["bookingData"] as List).length}',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isGoldPayment) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(
                    color: UIColor.gold,
                    fontFamily: 'Familiar',
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  'AED ${formatNumber(totalAmount)}',
                  style: TextStyle(
                    color: UIColor.gold,
                    fontFamily: 'Familiar',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}