import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';


void showAnimatedDialog(BuildContext context, AnimationController controller,Animation<double> animation,String title,String body,List<Widget> actions,{double? height}) {
    controller.forward(); 

    showDialog(
    
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ScaleTransition(
          scale: animation,
          child: Dialog(
            backgroundColor: UIColor.black,
            
            
           child:  Container(
            height: height?? 230.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 22.w,vertical: 22.h),
            decoration: BoxDecoration(
              border: Border.all(color: UIColor.gold),
              borderRadius: BorderRadius.circular(22.sp)
            ),
           
          
             child: Column(
             
               children: [
                Text(title,style: TextStyle(color: UIColor.gold,fontSize: 19.sp,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                SizedBox(height: 10.h,),
                Text(body, textAlign: TextAlign.center, style: TextStyle(color: UIColor.gold,fontSize: 16.sp,fontWeight: FontWeight.w300,)),
                   Spacer(),
                 Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: actions
                    ),
                
               ],
             ),
           ),
          ),
        );
      },
    ).then((_) {
      controller.reverse(); // Ensure the animation resets after dialog closes
    });
  }

  void showAnimatedDialog2(BuildContext context, AnimationController controller,Animation<double> animation,String title,String body,List<Widget> actions,{double? height}) {
    controller.forward(); 

    showDialog(
    
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ScaleTransition(
          scale: animation,
          child: Dialog(
            backgroundColor: UIColor.black,
            
            
           child:  Container(
            height: height?? 350.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 22.w,vertical: 22.h),
            decoration: BoxDecoration(
              border: Border.all(color: UIColor.gold),
              borderRadius: BorderRadius.circular(22.sp)
            ),
           
          
             child: Column(
             
               children: [
                Text(title,style: TextStyle(color: UIColor.gold,fontSize: 19.sp,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                SizedBox(height: 10.h,),
                Text(body, textAlign: TextAlign.center, style: TextStyle(color: UIColor.gold,fontSize: 16.sp,fontWeight: FontWeight.w300,)),
                 
              Expanded(
                child: Column(
                  children:  actions,
                ),
              )
                
               ],
             ),
           ),
          ),
        );
      },
    ).then((_) {
      controller.reverse(); // Ensure the animation resets after dialog closes
    });
  }

  