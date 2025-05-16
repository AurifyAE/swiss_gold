import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final String data;
  const CustomTile({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
          border: Border.all(
            color: UIColor.gold,
          ),
          borderRadius: BorderRadius.circular(15.sp)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            title,
            style: TextStyle(color: UIColor.gold,                fontFamily: 'Familiar',
 fontSize: 18.sp),
          ),
          Text(
            data,
            style: TextStyle(color: UIColor.gold,                fontFamily: 'Familiar',
 fontSize: 18.sp),
          ),
        ],
      ),
    );
  }
}
