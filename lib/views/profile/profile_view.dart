import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_alert.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/profile_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/profile/change_password_view.dart';

import '../../core/view_models/auth_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  bool? isGuest;
  AnimationController? animationController;
  Animation<double>? animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().getProfile();
      checkGuest();
    });
    animationController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 300), // Adjust duration for animation
    );
    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );
  }

  checkGuest() async {
    isGuest = await LocalStorage.getBool('isGuest');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: UIColor.gold,
            )),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Consumer<ProfileViewModel>(
          builder: (context, model, child) => model.state == ViewState.loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: UIColor.gold,
                  ),
                )
              : model.userModel == null
                  ? SizedBox.shrink()
                  : Column(
                    
                      children: [
                         isGuest == true?SizedBox(height: 50.h,):SizedBox.shrink(),
                        Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: UIColor.gold,
                            ),
                            borderRadius: BorderRadius.circular(100.sp),
                          ),
                          child: Icon(
                            PhosphorIcons.user(),
                            color: UIColor.gold,
                            size: 80.sp,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          model.userModel!.userName.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 22.sp,
                          ),
                        ),
                         isGuest == false?
                        Text(
                          model.userModel!.mobile.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 18.sp,
                            fontFamily: 'Familiar',
                          ),
                        ):SizedBox.shrink(),
                         isGuest == false?
                        Text(
                          model.userModel!.location.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 18.sp,
                            fontFamily: 'Familiar',
                          ),
                        ):SizedBox.shrink(),
                         isGuest == false?
                        Text(
                          model.userModel!.category.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 18.sp,
                            fontFamily: 'Familiar',
                          ),
                        ):SizedBox.shrink(),
                         isGuest == false?
                        SizedBox(
                          height: 20,
                        ):SizedBox.shrink(),
                        isGuest == false
                            ? CustomOutlinedBtn(
                                borderRadius: 22.sp,
                                borderColor: UIColor.gold,
                                padH: 5.w,
                                padV: 15.h,
                                btnText: 'Change password',
                                btnTextColor: UIColor.gold,
                                onTapped: () {
                                  navigateWithAnimationTo(
                                      context, ChangePasswordView(), 1, 0);
                                },
                              )
                            : SizedBox.shrink(),
                        SizedBox(
                          height: 20.h,
                        ),
                        CustomOutlinedBtn(
                          borderRadius: 22.sp,
                          borderColor: UIColor.gold,
                          padH: 5.w,
                          padV: 15.h,
                          btnText: 'Logout',
                          btnTextColor: UIColor.gold,
                          onTapped: () {
                            showAnimatedDialog(
                                context,
                                animationController!,
                                animation!,
                                height: 210.h,
                                'Ready to Log Out?',
                                'Are you sure you want to log out? You can sign back in anytime',
                                [
                                  Flexible(
                                      child: CustomOutlinedBtn(
                                    borderRadius: 12.sp,
                                    borderColor: UIColor.gold,
                                    btnText: 'Logout',
                                    btnTextColor: UIColor.gold,
                                    padH: 12.w,
                                    padV: 12.h,
                                    onTapped: () {
                                      LocalStorage.remove([
                                        'userId',
                                        'userName',
                                        'location',
                                        'category',
                                        'mobile',
                                        'isGuest'
                                      ]).then(
                                        (_) {
                                          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.logout();

                                          Navigator.pushAndRemoveUntil(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginView(),
                                              ),
                                              (route) => false);
                                        },
                                      );
                                    },
                                  )),
                                  Spacer(),
                                  Flexible(
                                      child: CustomOutlinedBtn(
                                          borderRadius: 12.sp,
                                          btnText: 'Cancel',
                                                                              btnTextColor: UIColor.gold,

                                          borderColor: UIColor.gold,
                                          padH: 12.w,
                                          padV: 12.h,
                                          onTapped: () {
                                            Navigator.pop(context);
                                          }))
                                ]);
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
