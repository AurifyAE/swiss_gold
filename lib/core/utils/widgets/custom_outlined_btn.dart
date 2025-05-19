import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class CustomOutlinedBtn extends StatelessWidget {
  final void Function()? onTapped;
  final String? btnText;
  final double borderRadius;
  final Color? bgColor;
  final IconData? btnIcon;
  final Color borderColor;
  final Color? btnTextColor;
  final Color? iconColor;
  final double padH;
  final double padV;
  final IconData? suffixIcon;
  final MainAxisAlignment? align;
  final double? fontSize;
  final double? width;
  final double? height;

  const CustomOutlinedBtn(
      {super.key,
      this.onTapped,
      this.btnText,
      this.bgColor,
      this.btnIcon,
      required this.borderRadius,
      required this.borderColor,
      this.btnTextColor,
      this.iconColor,
      required this.padH,
      required this.padV,
      this.fontSize,
      this.width,
      this.height,
      this.align,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            color: bgColor?? Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: align ?? MainAxisAlignment.center,
            children: [
              btnIcon != null
                  ? Icon(
                      btnIcon,
                      color: iconColor,
                      size: 25.sp,
                    )
                  : SizedBox.shrink(),
              btnIcon != null && btnText != null
                  ? SizedBox(
                      width: 10.w,
                    )
                  : SizedBox.shrink(),
              btnText != null
                  ? Text(
                      btnText!,
                      style: TextStyle(
                          fontFamily: 'Familiar',
                          color: btnTextColor,
                          fontSize: fontSize ?? 14.sp),
                    )
                  : SizedBox.shrink(),
              suffixIcon != null ? Spacer() : SizedBox.shrink(),
              suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: UIColor.gold,
                      size: 16.sp,
                    )
                  : SizedBox.shrink()
            ],
          )),
    );
  }
}
