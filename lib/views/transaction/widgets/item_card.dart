// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/money_format_heper.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  
  // ignore: use_super_parameters
  const TransactionItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.type == 'CREDIT';
    final String formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.createdAt);
    final String icon = _getTransactionIcon(transaction.method);
    final Color amountColor = isCredit ? Colors.green : Colors.red;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(50, 255, 255, 255),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            // Transaction icon
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: UIColor.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Center(
                child: Icon(
                  icon == 'attach_money' 
                      ? Icons.attach_money 
                      : icon == 'savings' 
                          ? Icons.savings 
                          : Icons.swap_horiz,
                  color: UIColor.gold,
                  size: 24.r,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTransactionTitle(transaction),
                        style: TextStyle(
                          fontFamily: 'Familiar',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        ),
                      ),
                      Text(
                        '${isCredit ? '+' : '-'} ${transaction.balanceType == 'GOLD' ? '${transaction.amount.toStringAsFixed(3)} g' : 'AED ${formatNumber(transaction.amount)}'}',
                        style: TextStyle(
                          fontFamily: 'Familiar',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    transaction.transactionId,
                    style: TextStyle(
                      fontFamily: 'Familiar',
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                     formattedDate,
                    style: TextStyle(
                      fontFamily: 'Familiar',
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTransactionTitle(Transaction transaction) {
    if (transaction.method == 'RECEIVED_GOLD') {
      return 'Gold Received';
    } else if (transaction.method == 'RECEIVED_CASH') {
      return 'Cash Received';
    } else if (transaction.method == 'CASH') {
      return transaction.type == 'DEBIT' ? 'Cash Payment' : 'Cash Deposit';
    } else if (transaction.method == 'BANK') {
      return transaction.type == 'DEBIT' ? 'Bank Payment' : 'Bank Deposit';
    } else if (transaction.method == 'GOLD') {
      return transaction.type == 'DEBIT' ? 'Gold Used' : 'Gold Added';
    }
    return transaction.method;
  }
  
  String _getTransactionIcon(String method) {
    if (method.contains('GOLD')) {
      return 'savings';
    } else if (method.contains('CASH') || method == 'BANK') {
      return 'attach_money';
    }
    return 'swap_horiz';
  }
}