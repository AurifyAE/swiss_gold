import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';

class CartCard extends StatelessWidget {
  final String prodImg;
  final String price;
  final String prodTitle;
  final String type;
  final int quantity;
  final bool state;
  final void Function()? onDecrementTapped;
  final void Function()? onIncrementTapped;
  final void Function()? onRemoveTapped;

  const CartCard({
    super.key,
    required this.prodImg,
    required this.price,
    required this.prodTitle,
    required this.quantity,
    this.onDecrementTapped,
    this.onIncrementTapped,
    this.onRemoveTapped,
    required this.state,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: UIColor.gold,
        ),
        borderRadius: BorderRadius.circular(22.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12.sp),
              child: CachedNetworkImage(
                imageUrl: prodImg,
                width: 80.w,
              )),
          SizedBox(
            width: 10.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${prodTitle.toString().length > 12 ? prodTitle.toString().substring(0, 12) : prodTitle}..',
                
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: UIColor.gold, fontSize: 19.sp,),
              ),
              //  SizedBox(
              //   height: 5.h,
              // ),
              // Text(
              //   type,
              //   style: TextStyle(color: UIColor.gold, fontSize: 16.sp),
              // ),
              //  SizedBox(
              //   height: 5.h,
              // ),
              // Text(
              //   price,
              //   style: TextStyle(color: UIColor.gold, fontSize: 16.sp),
              // ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                children: [
                 GestureDetector(
                    onTap: onDecrementTapped,
                    child: Icon(Icons.remove, color: UIColor.gold,size: 30.sp,),
                  
                  ),
                  SizedBox(width: 10.w,),
                  state
                      ? Center(
                          child: SizedBox(
                          width: 15.w,
                          height: 15.h,
                          child: CircularProgressIndicator(
                            color: UIColor.gold,
                            strokeWidth: 3,
                          ),
                        ))
                      : Text(
                          quantity.toString(),
                          style:
                              TextStyle(color: UIColor.gold, fontSize: 19.sp),
                        ),
                                          SizedBox(width: 10.w,),

                  GestureDetector(
                    onTap: onIncrementTapped,
                    child: Icon(Icons.add, color: UIColor.gold,size: 30.sp,),
                  
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          CustomOutlinedBtn(
            borderRadius: 22.sp,
            borderColor: UIColor.gold,
            padH: 12.w,
            padV: 5.h,
            onTapped: onRemoveTapped,
            btnText: 'Remove',
            btnTextColor: UIColor.gold,
          )
        ],
      ),
    );
  }
}
