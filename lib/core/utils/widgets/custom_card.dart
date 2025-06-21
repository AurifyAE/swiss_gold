
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

import '../money_format_heper.dart';

class CustomCard extends StatelessWidget {
  final String prodImg;
  final String title;
  final double price;
  final String? subTitle;
  final int quantity;
  final void Function()? onTap;
  final void Function()? onIncrement;
  final void Function()? onDecrement;
  final void Function()? onAddToCart;
  final void Function(int)? onQuantityEntered;
  
  const CustomCard({
    super.key,
    required this.prodImg,
    required this.quantity,
    required this.title,
    required this.price,
    this.subTitle,
    this.onTap,
    this.onIncrement,
    this.onDecrement,
    this.onAddToCart,
    this.onQuantityEntered,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: UIColor.gold),
          borderRadius: BorderRadius.circular(15.sp)
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product info section (left side)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: UIColor.gold,
                        fontFamily: 'Familiar',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 5.h),
                    // Text(
                    //   subTitle ?? '',
                    //   style: TextStyle(
                    //     color: UIColor.gold.withOpacity(0.8),
                    //     fontFamily: 'Familiar',
                    //     fontSize: 14.sp,
                    //   ),
                    // ),
                    // SizedBox(height: 5.h),
                    Text(
                     'AED ${formatNumber(price)}',
                      style: TextStyle(
                        color: UIColor.gold,
                        fontFamily: 'Familiar',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quantity controls (right side)
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: onDecrement,
                      child: CircleAvatar(
                        radius: 18.sp,
                        backgroundColor: UIColor.gold,
                        child: Icon(
                          Icons.remove,
                          color: UIColor.black,
                          size: 20.sp,
                        )
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Show dialog for entering quantity
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String newQuantity = quantity.toString();
                            return AlertDialog(
                              backgroundColor: UIColor.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: UIColor.gold, width: 2),
                              ),
                              title: Text(
                                'Enter Quantity',
                                style: TextStyle(color: UIColor.gold),
                              ),
                              content: TextField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: UIColor.gold),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: UIColor.gold),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: UIColor.gold),
                                  ),
                                ),
                                onChanged: (value) {
                                  // Allow only digits
                                  if (value.isNotEmpty && int.tryParse(value) != null) {
                                    newQuantity = value;
                                  }
                                },
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: UIColor.gold),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'OK',
                                    style: TextStyle(color: UIColor.gold),
                                  ),
                                  onPressed: () {
                                    if (newQuantity.isNotEmpty && int.tryParse(newQuantity) != null) {
                                      // Call the provided callback with the new quantity
                                      if (onQuantityEntered != null) {
                                        onQuantityEntered!(int.parse(newQuantity));
                                      }
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        width: 35.w,
                        child: Center(
                          child: Text(
                            quantity.toString(),
                            style: TextStyle(
                              color: UIColor.gold,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onIncrement,
                      child: CircleAvatar(
                        radius: 18.sp,
                        backgroundColor: UIColor.gold,
                        child: Icon(
                          Icons.add,
                          color: UIColor.black,
                          size: 20.sp,
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}