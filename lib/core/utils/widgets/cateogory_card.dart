import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String img;
  final Function()? onTap;
  const CategoryCard({super.key, required this.name, required this.img, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        width: 100.w,
       
        decoration: BoxDecoration(
            border: Border.all(color: UIColor.gold),
            borderRadius: BorderRadius.circular(14.sp)),
        child: Column(
          children: [
            CachedNetworkImage(imageUrl: img,progressIndicatorBuilder: (context, url, progress) => CategoryShimmer(width: 80,),),
            SizedBox(height: 5.h),
            Text(
              name,
              style: TextStyle(color: UIColor.gold, fontSize: 16.sp),
            )
          ],
        ),
      ),
    );
  }
}
