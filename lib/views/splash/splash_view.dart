import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/views/bottom_nav/bottom_nav.dart';

import 'package:swiss_gold/views/login/login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      () {
        checkState();
      },
    );
  }

  checkState() async {
    final userId = await LocalStorage.getString('userId');
     final isGuest = await LocalStorage.getBool('isGuest');
    if (!mounted) return;
    if (userId != null || isGuest==true ) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNav(),
          ),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginView(),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              ImageAssets.splashLogo,
              height: 120.h,
            ),
            Text('Swiss Gold',style: TextStyle(color: UIColor.gold,fontSize: 18.sp,                fontFamily: 'Familiar',
),textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}
