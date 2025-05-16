import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class CustomCard extends StatelessWidget {
  final String prodImg;
  final String title;
  final String price;
  final String? subTitle;
  final int quantity;
  final void Function()? onTap;
  final void Function()? onIncrement;
  final void Function()? onDecrement;
  final void Function()? onAddToCart;
  final void Function(int)? onQuantityEntered; // New callback for direct quantity input
  
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
    this.onQuantityEntered, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    price.split('.');


    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: UIColor.gold),
            borderRadius: BorderRadius.circular(22.sp)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center(
              //   child: ClipRRect(
              //       borderRadius: BorderRadius.circular(12.sp),
              //       child: CachedNetworkImage(
              //         imageUrl: prodImg,
              //         progressIndicatorBuilder: (context, url, progress) =>
              //             CategoryShimmer(
              //           height: 100.h,
              //           width: 100.w,
              //         ),
              //         fit: BoxFit.cover,
              //         height: 100.h,
              //         width: 100.w,
              //       )),
              // ),
              // SizedBox(
              //   height: 20.h,
              // ),
              Text(
                title,
                overflow: TextOverflow.visible,
                maxLines: null,
                style: TextStyle(
                    color: UIColor.gold,
                    fontFamily: 'Familiar',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),

              // SizedBox(
              //   height: 20.h,
              // ),

              // RichText(
              //   text: TextSpan(
              //     children: [
              //       TextSpan(
              //         text: integerPart,
              //         style: TextStyle(
              //           color: UIColor.gold,
              //           fontFamily: 'Familiar',

              //           fontWeight: FontWeight.bold,
              //           fontSize: 16.sp, // Regular font size
              //         ),
              //       ),
              //       TextSpan(
              //         text: '.$decimalPart',
              //         style: TextStyle(
              //           fontFamily: 'Familiar',

              //           fontWeight: FontWeight.bold,
              //           color: UIColor.gold,
              //           fontSize:
              //               14.sp, // Smaller font size for the decimal part
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Spacer(),

              Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: onDecrement,
                    child: CircleAvatar(
                        radius: 21.sp,
                        backgroundColor: UIColor.gold,
                        child: Icon(
                          Icons.remove,
                          color: UIColor.black,
                          size: 25.sp,
                        )),
                  ),
                  // SizedBox(
                  //   width: 10.w,
                  // ),
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
    width: 20.w, // Limit the width space for the number
    height: 40.h,
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          quantity.toString(),
          style: TextStyle(
            color: UIColor.gold,
            fontSize: 26.sp,
          ),
        ),
      ),
    ),
  ),
),
                  // SizedBox(
                  //   width: 10.w,
                  // ),
                  GestureDetector(
                    
                    onTap: onIncrement,
                    child: CircleAvatar(
                        radius: 21.sp,
                        backgroundColor: UIColor.gold,
                        child: Icon(
                          Icons.add,
                          color: UIColor.black,
                          size: 25.sp,
                        )),
                  ), 
                ],
              ),
              // SizedBox(
              //   height: 10.h,
              // ),
              // GestureDetector(
              //   onTap: onAddToCart,
              //   child: Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
              //     decoration: BoxDecoration(
              //         color: UIColor.gold,
              //         borderRadius: BorderRadius.circular(8.sp)),
              //     child: Text(
              //       'Add to cart',
              //       textAlign: TextAlign.center,
              //       style: TextStyle(
              //         fontFamily: 'Familiar',

              //         fontWeight: FontWeight.bold,
              //         color: UIColor.black,
              //         fontSize: 14.sp, // Smaller font size for the decimal part
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
