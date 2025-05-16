// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/money_format_heper.dart';
// import 'package:swiss_gold/core/viewmodels/transaction_view_model.dart';

import '../../../core/view_models/transaction_view_model.dart';

class BalanceCard extends StatelessWidget {
  final BalanceInfo? balanceInfo;
  final Summary? summary;

  // ignore: use_super_parameters
  const BalanceCard({
    Key? key,
    this.balanceInfo,
    this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
        builder: (context, transactionViewModel, _) {
      final isLoading = transactionViewModel.state == ViewState.loading;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: UIColor.gold),
          boxShadow: [
            BoxShadow(
              color: UIColor.gold.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? _buildShimmerContent()
            : _buildCardContent(context, transactionViewModel),
      );
    });
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with shimmer
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120.w,
                            height: 15.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            width: 80.w,
                            height: 15.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 1,
                        width: 60.w,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                // Shimmer circle for refresh button
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Gold balance shimmer
            _buildBalanceSectionShimmer(),

            SizedBox(height: 16.h),

            // Cash balance shimmer
            _buildBalanceSectionShimmer(),

            SizedBox(height: 20.h),

            // Transaction summary shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTransactionSummaryShimmer(),
                _buildTransactionSummaryShimmer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSectionShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.white,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 150.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionSummaryShimmer() {
    return Row(
      children: [
        Container(
          width: 16.r,
          height: 16.r,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          width: 60.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(
      BuildContext context, TransactionViewModel transactionViewModel) {
    // Determine which gold value to display
    final displayGoldValue = balanceInfo?.availableGold == 0
        ? balanceInfo?.totalGoldBalance
        : balanceInfo?.availableGold;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gold accent line and refresh button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontFamily: 'Familiar',
                            color: UIColor.gold,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          balanceInfo?.name ?? '',
                          style: TextStyle(
                            fontFamily: 'Familiar',
                            color: UIColor.gold.withOpacity(0.8),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      height: 1,
                      width: 60.w,
                      color: UIColor.gold,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w,),
              // Refresh button that calls refreshTransactions from the ViewModel
              InkWell(
                onTap: () => transactionViewModel.refreshTransactions(),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: UIColor.gold.withOpacity(0.5)),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: UIColor.gold,
                    size: 16.r,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Redesigned balance section for better overflow handling
          Column(
            children: [
              // Gold balance section
              _buildBalanceSection(
                title: 'Gold Balance',
                icon: Icons.savings,
                value: '${displayGoldValue?.toStringAsFixed(2) ?? '0.00'} g',
              ),

              SizedBox(height: 16.h),

              // Cash balance section
              _buildBalanceSection(
                title: 'Cash Balance',
                icon: Icons.account_balance_wallet,
                value: 'AED ${formatNumber(balanceInfo?.cashBalance ?? 0)}',
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Transaction summary in a more elegant row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTransactionSummary(
                'Credit',
                (summary?.gold.creditCount ?? 0) +
                    (summary?.cash.creditCount ?? 0),
                Icons.arrow_circle_up_outlined,
              ),
              _buildTransactionSummary(
                'Debit',
                (summary?.gold.debitCount ?? 0) +
                    (summary?.cash.debitCount ?? 0),
                Icons.arrow_circle_down_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection({
    required String title,
    required IconData icon,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: UIColor.gold.withOpacity(0.5)),
          ),
          child: Icon(
            icon,
            color: UIColor.gold,
            size: 25.r,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Familiar',
                  color: UIColor.gold.withOpacity(0.7),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Familiar',
                    color: UIColor.gold,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionSummary(String type, int count, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: UIColor.gold,
          size: 16.r,
        ),
        SizedBox(width: 6.w),
        Text(
          '$type: ',
          style: TextStyle(
            fontFamily: 'Familiar',
            color: UIColor.gold.withOpacity(0.8),
            fontSize: 13.sp,
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Familiar',
            color: UIColor.gold,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
