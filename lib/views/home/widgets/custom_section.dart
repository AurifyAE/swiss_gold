import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';

class CustomSection extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> sectionData;
  final Function()? onTap;
  const CustomSection(
      {super.key,
      required this.sectionTitle,
      required this.sectionData,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      margin:  EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(color: UIColor.gold),
        borderRadius: BorderRadius.circular(22.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionTitle,
                  style: TextStyle(color: UIColor.gold, fontSize: 22.sp,                fontFamily: 'Familiar',
),
                ),
                CustomOutlinedBtn(
                  borderRadius: 22.sp,
                  borderColor: UIColor.gold,
                  padH: 5.w,
                  fontSize: 16.sp,
                  padV: 5.h,
                  btnText: 'View All',
                  btnIcon: Icons.arrow_forward,
                  iconColor: UIColor.gold,
                  onTapped: onTap,
                  btnTextColor: UIColor.gold,
                )
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: sectionData,
          ),
          
        ],
        
      ),
    );
  }
}
