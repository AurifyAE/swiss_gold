// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/transaction_view_model.dart';
import 'package:swiss_gold/views/bank/bank_details.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/profile/profile_view.dart';
import 'package:swiss_gold/views/transaction/transaction_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swiss_gold/views/transaction/widgets/base_card.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  bool isGuestUser = false;

 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final transactionModel = Provider.of<TransactionViewModel>(context, listen: false);
    
    // First check guest mode
    await cartViewModel.checkGuestMode();
    
    setState(() {
      isGuestUser = cartViewModel.isGuest ?? false;
    });
    
    // Only fetch transactions if not a guest
    if (!isGuestUser) {
      // The updated fetchTransactions will handle initialization
      transactionModel.fetchTransactions();
    }
  });
  }

  @override
  Widget build(BuildContext context) {
    final InAppReview inAppReview = InAppReview.instance;

    Future<void> openUrl(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        // Get the current guest status from CartViewModel
        final bool isGuest = cartViewModel.isGuest ?? false;
        
        return Consumer<TransactionViewModel>(
          builder: (context, transactionModel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Add Balance Card if not guest and data is loaded
                    if (!isGuest && 
                        transactionModel.state != ViewState.loading && 
                        transactionModel.balanceInfo != null && 
                        transactionModel.summary != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: BalanceCard(
                          balanceInfo: transactionModel.balanceInfo!,
                          summary: transactionModel.summary!,
                        ),
                      ),
                    
                    // Show loading indicator while fetching data
                    if (!isGuest && transactionModel.state == ViewState.loading)
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Container(
                          width: double.infinity,
                          height: 180.h,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: UIColor.gold.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(color: UIColor.gold),
                          ),
                        ),
                      ),
                    
                    // Show login prompt if guest
                    if (isGuest)
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                UIColor.gold.withOpacity(0.8),
                                UIColor.gold,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.white,
                                  size: 40.r,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Please login to view your balance',
                                  style: TextStyle(
                                    fontFamily: 'Familiar',
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                CustomOutlinedBtn(
                                  borderRadius: 22.sp,
                                  borderColor: Colors.white,
                                  padH: 10.w,
                                  padV: 10.h,
                                  width: 150.w,
                                  btnText: 'Login',
                                  btnTextColor: Colors.white,
                                  fontSize: 16.sp,
                                  onTapped: () {
                                    navigateTo(context, LoginView());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    CustomOutlinedBtn(
                      borderRadius: 12.sp,
                      borderColor: UIColor.gold,
                      padH: 20.w,
                      padV: 20.h,
                      btnText: 'Profile',
                      btnIcon: PhosphorIcons.userCircle(),
                      suffixIcon: Icons.arrow_forward_ios,
                      iconColor: UIColor.gold,
                      btnTextColor: UIColor.gold,
                      fontSize: 17.sp,
                      align: MainAxisAlignment.start,
                      onTapped: () {
                        navigateTo(context, ProfileView());
                      },
                    ),
                    SizedBox(height: 20.h),
                    
                    // Only show transaction history button if not in guest mode
                    if (!isGuest)
                      Column(
                        children: [
                          CustomOutlinedBtn(
                            borderRadius: 12.sp,
                            borderColor: UIColor.gold,
                            padH: 20.w,
                            padV: 20.h,
                            btnIcon: PhosphorIcons.article(),
                            iconColor: UIColor.gold,
                            btnText: 'Payment history',
                            btnTextColor: UIColor.gold,
                            suffixIcon: Icons.arrow_forward_ios,
                            fontSize: 17.sp,
                            align: MainAxisAlignment.start,
                            onTapped: () {
                              navigateTo(context, TransactionHistoryView());
                            },
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    if (!isGuest)
                      Column(
                        children: [
                          CustomOutlinedBtn(
                            borderRadius: 12.sp,
                            borderColor: UIColor.gold,
                            padH: 20.w,
                            padV: 20.h,
                            btnIcon: PhosphorIcons.bank(),
                            iconColor: UIColor.gold,
                            btnText: 'Bank details',
                            btnTextColor: UIColor.gold,
                            suffixIcon: Icons.arrow_forward_ios,
                            fontSize: 17.sp,
                            align: MainAxisAlignment.start, 
                            onTapped: () {
                              navigateTo(context, BankDetailsView());
                            },
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),

                    CustomOutlinedBtn(
                      borderRadius: 12.sp,
                      borderColor: UIColor.gold,
                      padH: 20.w,
                      padV: 20.h,
                      btnText: 'Terms and conditions',
                      btnIcon: PhosphorIcons.link(),
                      iconColor: UIColor.gold,
                      btnTextColor: UIColor.gold,
                      suffixIcon: Icons.arrow_forward_ios,
                      fontSize: 17.sp,
                      align: MainAxisAlignment.start,
                      onTapped: () {
                        openUrl('https://rakgolds.ae/terms-conditions');
                      },
                    ),
                    SizedBox(height: 20.h),

                    CustomOutlinedBtn(
                      borderRadius: 12.sp,
                      borderColor: UIColor.gold,
                      padH: 20.w,
                      padV: 20.h,
                      suffixIcon: Icons.arrow_forward_ios,
                      btnText: 'FAQs',
                      btnTextColor: UIColor.gold,
                      btnIcon: PhosphorIcons.link(),
                      iconColor: UIColor.gold,
                      fontSize: 17.sp,
                      align: MainAxisAlignment.start,
                      onTapped: () {
                        openUrl('https://rakgolds.ae/faq');
                      },
                    ),
                    SizedBox(height: 20.h),

                    CustomOutlinedBtn(
                      borderRadius: 12.sp,
                      borderColor: UIColor.gold,
                      padH: 20.w,
                      padV: 20.h,
                      btnIcon: PhosphorIcons.paperPlaneTilt(),
                      iconColor: UIColor.gold,
                      btnText: 'Share App',
                      suffixIcon: Icons.arrow_forward_ios,
                      btnTextColor: UIColor.gold,
                      fontSize: 17.sp,
                      align: MainAxisAlignment.start,
                      onTapped: () async {
                        Share.share('Discover the best gold deals on Swiss Gold! Check it out now!');
                      },
                    ),
                    SizedBox(height: 20.h),

                    CustomOutlinedBtn(
                      borderRadius: 12.sp,
                      borderColor: UIColor.gold,
                      padH: 20.w,
                      padV: 20.h,
                      btnText: 'Rate Us',
                      suffixIcon: Icons.arrow_forward_ios,
                      btnIcon: PhosphorIcons.star(),
                      iconColor: UIColor.gold,
                      btnTextColor: UIColor.gold,
                      fontSize: 17.sp,
                      align: MainAxisAlignment.start,
                      onTapped: () async {
                        inAppReview.openStoreListing(appStoreId: 'ios app id');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}