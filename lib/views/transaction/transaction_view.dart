import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/transaction_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';

import '../../core/view_models/cart_view_model.dart';
import 'widgets/item_card.dart';

class TransactionHistoryView extends StatefulWidget {
  const TransactionHistoryView({
    super.key, 
  });

  @override
  State<TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<TransactionHistoryView> {
   bool isGuestUser = false;
  final ScrollController _scrollController = ScrollController();
  final List<String> filters = ['All', 'Gold', 'Cash', 'Credit', 'Debit'];
  

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Check login status from CartViewModel first before fetching transactions
   final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final transactionModel = Provider.of<TransactionViewModel>(context, listen: false);
    
    // First check guest status from CartViewModel
setState(() {
      isGuestUser = cartViewModel.isGuest ?? false;
    });
    
    // Only fetch transactions if not a guest
    if (!isGuestUser) {
      // The updated fetchTransactions will handle initialization
      transactionModel.fetchTransactions();
    }
  });
  // });
  
  _scrollController.addListener(() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final cartModel = context.read<CartViewModel>();
      final transactionModel = context.read<TransactionViewModel>();
      if (!cartModel.isGuest! && transactionModel.pagination != null && 
          transactionModel.pagination!.currentPage < transactionModel.pagination!.totalPages) {
        transactionModel.loadMoreTransactions();
      }
    }
  });
}
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: TextStyle(
            fontFamily: 'Familiar',
            color: UIColor.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: UIColor.gold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: UIColor.gold),
            onPressed: () {
              final model = context.read<TransactionViewModel>();
              if (!isGuestUser) {
                model.refreshTransactions();
              }
            },
          ),
        ],
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, model, child) {
          // Check if user is a guest
          // final bool isGuestUser = model.isGuest;
          
          // If user is a guest, show login UI
          if (isGuestUser) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 60.r,
                    color: UIColor.gold,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Please login to view your transaction history',
                    style: TextStyle(
                      color: UIColor.gold,
                      fontSize: 16.sp,
                      fontFamily: 'Familiar',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  CustomOutlinedBtn(
                    borderRadius: 22.sp,
                    borderColor: UIColor.gold,
                    padH: 10.w,
                    padV: 10.h,
                    width: 200.w,
                    btnText: 'Login',
                    btnTextColor: UIColor.gold,
                    fontSize: 22.sp,
                    onTapped: () {
                      navigateTo(context, LoginView());
                    },
                  ),
                ],
              ),
            );
          }
          
          // Loading state
          if (model.state == ViewState.loading) {
            return Center(
              child: CircularProgressIndicator(color: UIColor.gold),
            );
          } 
          // Error state
          else if (model.state == ViewState.error) {
            return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(
          //   'assets/images/empty_transactions.png', // Replace with your own asset
          //   width: 120.w,
          //   height: 120.h,
          //   color: UIColor.gold.withOpacity(0.7),
          // ),
          // Alternative if you don't have an image:
          Icon(
            Icons.history,
            size: 80.r,
            // ignore: deprecated_member_use
            color: UIColor.gold.withOpacity(0.7),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontFamily: 'Familiar',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Your transaction history will appear here once you make your first purchase.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Familiar',
                fontSize: 14.sp,
                color: Colors.grey[400],
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          CustomOutlinedBtn(
            borderRadius: 22.sp,
            borderColor: UIColor.gold,
            padH: 10.w,
            padV: 10.h,
            width: 200.w,
            btnText: 'Shop Now',
            btnTextColor: UIColor.gold,
            fontSize: 16.sp,
            onTapped: () {
              // Navigate to shop/home page
              Navigator.pop(context);
            },
          ),
        ], 
      ),
    );
          }
          
          // Successful data loaded state
          return RefreshIndicator(
            color: UIColor.gold,
            onRefresh: () async {
              await model.fetchTransactions();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
               
                
                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filters.map((filter) {
                          final isSelected = model.selectedFilter == filter;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                ),
                              ),
                              backgroundColor: Colors.black,
                              selectedColor: UIColor.gold,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: UIColor.gold,
                                  width: 1,
                                ),
                              ),
                              onSelected: (selected) {
                                model.setFilter(filter);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Text(
                          'Transactions',
                          style: TextStyle(
                            fontFamily: 'Familiar',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(${model.filteredTransactions.length})',
                          style: TextStyle(
                            fontFamily: 'Familiar',
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        if (model.transactions.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              model.toggleSortOrder();
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Sort',
                                  style: TextStyle(
                                    fontFamily: 'Familiar',
                                    fontSize: 14.sp,
                                    color: UIColor.gold,
                                  ),
                                ),
                                Icon(
                                  model.isAscending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 16.r,
                                  color: UIColor.gold,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                model.filteredTransactions.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 60.r,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < model.filteredTransactions.length) {
                          final transaction = model.filteredTransactions[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            child: TransactionItem(transaction: transaction),
                          );
                        } else if (model.loadingMore) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.r),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: UIColor.gold,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: model.filteredTransactions.length + (model.loadingMore ? 1 : 0),
                    ),
                  ),
                  
                // Add spacing at the bottom
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}