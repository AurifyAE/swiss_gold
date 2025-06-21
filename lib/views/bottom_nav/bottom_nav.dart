import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/views/bottom_nav/no_internet_view.dart';
import 'package:swiss_gold/views/notification/notification_view.dart';
import 'package:swiss_gold/views/order_history/order_history.dart';
import 'package:swiss_gold/views/pending_orders/pending_approval_screen.dart';
import 'package:swiss_gold/views/support/contact_view.dart';
import 'package:swiss_gold/views/home/home_view.dart';
import 'package:swiss_gold/views/more/more_view.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../core/view_models/cart_view_model.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;
  bool isConnected = true;
  bool isGuestUser = false;
  StreamSubscription? internetStreamSubscription;

  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void checkConnection() async {
    internetStreamSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {

      if (mounted) {
        switch (status) {
          case InternetStatus.connected:
            if (!isConnected) {
              _checkInternetAccess().then((isOnline) {
                if (isOnline) {
                  setState(() {
                    isConnected = true;
                  });
                } else {
                  _retryConnection();
                }
              });
            }
            break;
          case InternetStatus.disconnected:
            if (isConnected) {
              setState(() {
                isConnected = false;
              });
              // print("Internet disconnected");
              _retryConnection();
            }
            break;
        }
      }
    });
  }

  void _retryConnection() async {
    await Future.delayed(Duration(seconds: 5));
    checkConnection(); // Recheck the connection
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  List screens = [HomeView(), OrderHistory(),  PendingApprovalScreen(),ContactView(), MoreView()];

  @override
  void initState() {
    super.initState();

    checkConnection();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      cartViewModel.checkGuestMode().then((_) {
        if (mounted) {
          setState(() {
            isGuestUser = cartViewModel.isGuest ?? false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(builder: (context, cartViewModel, child) {
      // Get the current guest status from CartViewModel
      final bool isGuest = cartViewModel.isGuest ?? false;

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 120.h,
          title: Image.asset(
            ImageAssets.mainLogo,
            width: 200.w,
          ),
          actions: [
            // Only show notification icon if NOT in guest mode
            if (!isGuest)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => NotificationView(),
                    ),
                  );
                },
                icon: Icon(
                  PhosphorIcons.bellSimple(PhosphorIconsStyle.bold),
                  color: UIColor.gold,
                  size: 32.sp,
                ),
              ),
            SizedBox(
              width: 10,
            )
          ],
        ),
        body: isConnected
            ? AnimatedSwitcher(
                duration: const Duration(
                    milliseconds: 400), // Duration of the fade effect
                child: screens[currentIndex],
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
              )
            : NoInternetView(onRetry: () {
                _retryConnection();
              }),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(
            fontFamily: 'Familiar',
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Familiar',
          ),
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            onTapped(index);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  PhosphorIcons.shoppingBagOpen(),
                  size: 32.sp,
                ),
                label: 'Shop'),
            BottomNavigationBarItem(
                icon: Icon(
                  PhosphorIcons.article(),
                  size: 32.sp,
                ),
                label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(
                  PhosphorIcons.list(),
                  size: 32.sp,
                ),
                label: 'Approval pending'),
            BottomNavigationBarItem(
                icon: Icon(
                  PhosphorIcons.headset(),
                  size: 32.sp,
                ),
                label: 'Contact'),
            BottomNavigationBarItem(
                icon: Icon(
                  PhosphorIcons.gearSix(),
                  size: 32.sp,
                ),
                label: 'More'),
          ],
        ),
      );
    });
  }
}
