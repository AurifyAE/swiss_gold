import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:swiss_gold/core/models/order_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/order_history/widgets/order_card.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  String query = 'All';
  int currentIndex = 0;
  int currentPage = 1;
  int selectedFilterIndex = 0;
  bool isExpanded = false;
  ScrollController scrollController = ScrollController();
  List<String> filters = [
    "All",
    "User Approval Pending",
    "Processing",
    "Success",
    "Rejected"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<OrderHistoryViewModel>();
      model.checkGuestMode().then((_) {
        _loadOrders();
        
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            final model = context.read<OrderHistoryViewModel>();
            if (currentPage < (model.orderModel?.pagination?.totalPage ?? 0)) {
              currentPage++;
              log('Loading more orders, page: $currentPage');
              model.getMoreOrderHistory(currentPage.toString(), query);
            }
          }
        });
      });
    });
  }

  void _loadOrders() {
    final model = context.read<OrderHistoryViewModel>();
    currentPage = 1; // Reset to first page when loading orders
    model.getOrderHistory('1', query);
  }

  Future<void> _handleRefresh() async {
    log('Refreshing orders');
    final model = context.read<OrderHistoryViewModel>();
    currentPage = 1; // Reset to first page on refresh
    await model.getOrderHistory('1', query);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      filters.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: CustomOutlinedBtn(
                          borderRadius: 8.sp,
                          onTapped: () {
                            setState(() {
                              selectedFilterIndex = index;
                              currentPage = 1;
                              query = filters[index];
                            });
                            _loadOrders();
                            log('Selected filter: $query');
                          },
                          btnText: filters[index],
                          btnTextColor: selectedFilterIndex == index
                              ? UIColor.black
                              : UIColor.gold,
                          bgColor: selectedFilterIndex == index
                              ? UIColor.gold
                              : UIColor.black,
                          borderColor: selectedFilterIndex == index
                              ? UIColor.gold
                              : UIColor.gold,
                          padH: 8.w,
                          padV: 5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<OrderHistoryViewModel>(
        builder: (context, model, child) {
          if (model.state == ViewState.loading) {
            return Center(
              child: CircularProgressIndicator(
                color: UIColor.gold,
              ),
            );
          } else if (model.isGuest == true) {
            return Center(
              child: CustomOutlinedBtn(
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
            );
          } else if (model.allOrders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: UIColor.gold,
              backgroundColor: UIColor.black,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Center(
                    child: Text(
                      'No orders found',
                      style: TextStyle(
                        color: UIColor.gold,
                        fontSize: 16.sp,
                        fontFamily: 'Familiar',
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: UIColor.gold,
              backgroundColor: UIColor.black,
              child: Padding(
                padding: EdgeInsets.only(top: 0.h, left: 16.w, right: 16.w),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: model.allOrders.length,
                        itemBuilder: (context, index) {
                          final order = model.allOrders[index];
                          
                          return OrderCard(
                            status: order.orderStatus,
                            totalPrice: order.totalPrice,
                            orderRemark: order.orderRemark,
                            paymentMethod: order.paymentMethod,
                            transactionId: order.transactionId,
                            orderDate: order.orderDate,
                            pricingOption: order.pricingOption,
                            premiumAmount: order.premiumAmount != 0
                                ? order.premiumAmount.toString()
                                : null,
                            discountAmount: order.discountAmount != 0
                                ? order.discountAmount.toString()
                                : null,
                            expanded: isExpanded && currentIndex == index,
                            icon: isExpanded && currentIndex == index
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down_outlined,
                            onTap: () {
                              setState(() {
                                isExpanded = currentIndex == index ? !isExpanded : true;
                                currentIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              child: isExpanded && currentIndex == index
                                  ? SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: order.item.length,
                                        itemBuilder: (context, itemIndex) {
                                          final item = order.item[itemIndex];
                                          return Container(
                                            margin: EdgeInsets.only(
                                              bottom: 10.h,
                                              top: 20.h, 
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12.sp),
                                                  child: CachedNetworkImage(
                                                    imageUrl: item.product?.images.isNotEmpty == true
                                                        ? item.product!.images[0]
                                                        : '',
                                                    width: 50.w,
                                                    height: 50.w,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) {
                                                      return Image.asset(
                                                        ImageAssets.prod,
                                                        width: 80.w,
                                                        height: 80.w,
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 20.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.product?.title ?? 'Product',
                                                        style: TextStyle(
                                                          color: UIColor.gold,
                                                          fontSize: 16.sp,
                                                          fontFamily: 'Familiar',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        'AED ${item.product?.price ?? 0}',
                                                        style: TextStyle(
                                                          color: UIColor.gold,
                                                          fontSize: 16.sp,
                                                          fontFamily: 'Familiar',
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Quantity:',
                                                            style: TextStyle(
                                                              color: UIColor.gold,
                                                              fontSize: 16.sp,
                                                              fontFamily: 'Familiar',
                                                            ),
                                                          ),
                                                          SizedBox(width: 10.w),
                                                          Text(
                                                            item.quantity.toString(),
                                                            style: TextStyle(
                                                              color: UIColor.gold,
                                                              fontSize: 16.sp,
                                                              fontFamily: 'Familiar',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Status:',
                                                            style: TextStyle(
                                                              color: UIColor.gold,
                                                              fontSize: 16.sp,
                                                              fontFamily: 'Familiar',
                                                            ),
                                                          ),
                                                          SizedBox(width: 10.w),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: 5.w,
                                                              vertical: 1.h,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: _getStatusColor(item.status),
                                                              borderRadius:
                                                                  BorderRadius.circular(5.sp),
                                                            ),
                                                            child: Text(
                                                              item.status,
                                                              style: TextStyle(
                                                                color: UIColor.black,
                                                                fontSize: 9.sp,
                                                                fontFamily: 'Familiar',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${item.product?.weight ?? 0} g',
                                                      style: TextStyle(
                                                        color: UIColor.gold,
                                                        fontSize: 16.sp,
                                                        fontFamily: 'Familiar',
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Purity:',
                                                          style: TextStyle(
                                                            color: UIColor.gold,
                                                            fontSize: 16.sp,
                                                            fontFamily: 'Familiar',
                                                          ),
                                                        ),
                                                        SizedBox(width: 5.w),
                                                        Text(
                                                          '${item.product?.purity ?? 0}K',
                                                          style: TextStyle(
                                                            color: UIColor.gold,
                                                            fontSize: 16.sp,
                                                            fontFamily: 'Familiar',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      if (model.state == ViewState.loadingMore)
                        Padding(
                          padding: EdgeInsets.all(16.h),
                          child: CircularProgressIndicator(
                            color: UIColor.gold,
                          ),
                        ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
  
  // Helper method to determine status color 
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Rejected':
        return Colors.red;
      case 'Processing':
        return Colors.orange;
      case 'Success':
        return Colors.green;
      case 'Approved':
        return Colors.green;
      case 'Approval Pending':
        return Colors.blue;
      case 'UserApprovalPending': 
        return Colors.blue;
      default:
        return UIColor.gold;
    }
  }
  
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}