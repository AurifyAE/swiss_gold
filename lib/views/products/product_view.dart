import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_alert.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/views/delivery/delivery_view.dart';

class ProductView extends StatefulWidget {
  final List<String> prodImg;
  final String title;
  final String desc;
  final String pId;
  final num purity;
  final num weight;
  final bool stock;
  final String type;
  final num makingCharge;
  const ProductView({
    super.key,
    required this.prodImg,
    required this.title,
    required this.desc,
    required this.pId,
    required this.purity,
    required this.weight,
    required this.stock,
    required this.type,
    required this.makingCharge,
  });

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  int page2Index = 0;
  double price = 0;
  double goldBid = 0;
  double silverBid = 0;
  double copperBid = 0;
  double platinumBid = 0;
  double goldPrice = 0;
  double silverPrice = 0;
  double platinumPrice = 0;
  double copperPrice = 0;
  String selectedValue = '';
  DateTime selectedDate = DateTime.now();
  final PageController pageController = PageController();
  final PageController pageController2 = PageController();

  AnimationController? animationController;
  Animation<double>? animation;
  
  List<Map<String, dynamic>> bookingData = [];

  StreamSubscription? _marketDataSubscription;

  @override
  void initState() {
    super.initState();

    final orderHistoryViewModel = context.read<OrderHistoryViewModel>();
    if (orderHistoryViewModel.cashPricingModel == null) {
      orderHistoryViewModel.getCashPricing('Cash');
    }

    if (orderHistoryViewModel.bankPricingModel == null) {
      orderHistoryViewModel.getBankPricing('Bank');
    }

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );

    final productViewModel = context.read<ProductViewModel>();
    if (productViewModel.goldSpotRate == null) {
      productViewModel.getSpotRate();
    }

    _marketDataSubscription =
        ProductService.marketDataStream.listen((marketData) {
      String symbol = marketData['symbol'].toString().toLowerCase();

      if (mounted) {
        if (symbol == 'gold') {
          setState(() {
            goldBid = (marketData['bid'] is int)
                ? (marketData['bid'] as int).toDouble()
                : marketData['bid'];
          });
        }
      }
    });

    if (productViewModel.isGuest == null) {
      productViewModel.checkGuestMode();
    }
  }
  
  void incrementQuantity() {
    final String productId = widget.pId;
    
    // Update booking data for this product
    setState(() {
      bookingData = [
        {
          "productId": productId,
          "quantity": 1,
        }
      ];
    });
    
    // If user is not in guest mode, update cart on the server
    if (context.read<ProductViewModel>().isGuest == false) {
      context.read<CartViewModel>().incrementQuantity(
          {'pId': productId}).then((result) {
        if (result != null && result.success == true) {
        } else {
        }
      }).catchError((error) {
      });
    } else {
      // User in guest mode, use admin ID "gyu123" for the cart operations
      context.read<CartViewModel>().incrementQuantity(
          {'pId': productId, 'userId': 'gyu123'}).then((result) {
        if (result != null && result.success == true) {
        } else {
        }
      }).catchError((error) {
      });
    }
  }

  void navigateToDeliveryDetails({String? paymentMethod, String? pricingOption, String? amount}) {
    final effectivePaymentMethod = 
        selectedValue != 'Gold' ? (paymentMethod ?? 'Cash') : 'Gold';
    
    Map<String, dynamic> finalPayload = {
      "bookingData": bookingData,
      "paymentMethod": effectivePaymentMethod,
      if (selectedValue != 'Gold' && pricingOption != null)
        "pricingOption": pricingOption,
      "deliveryDate": selectedDate.toString().split(' ')[0]
    };

    if (selectedValue == 'Gold' && 
        pricingOption == 'Premium' && 
        amount != null) {
      finalPayload['premium'] = amount;
    }
    if (selectedValue != 'Gold' && 
        pricingOption == 'Discount' && 
        amount != null) {
      finalPayload['discount'] = amount;
    }

    navigateWithAnimationTo(
      context,
      DeliveryDetailsView(
        orderData: finalPayload,
        onConfirm: (deliveryDetails) {
          processOrder(finalPayload);
        },
      ),
      0,
      1,
    );
  }

  void processOrder(Map<String, dynamic> finalPayload) {
    
    if (finalPayload.containsKey("success") && finalPayload["success"] == true) {
      setState(() {
        selectedValue = '';
        bookingData.clear();
      });

      customSnackBar(
        bgColor: UIColor.gold,
        titleColor: UIColor.white,
        width: 130.w,
        context: context,
        title: 'Booking success'
      );
    } else {
      customSnackBar(
        bgColor: UIColor.gold,
        titleColor: UIColor.white,
        width: 130.w,
        context: context,
        title: 'Booking success' 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: CustomOutlinedBtn(
            btnText: 'Order now',
            btnTextColor: UIColor.gold,
            borderColor: UIColor.gold,
            borderRadius: 12.sp,
            iconColor: UIColor.gold,
            padH: 10.w,
            padV: 14.h,
            onTapped: () {
              // First increment the quantity
              incrementQuantity();
              
              // Show payment options dialog
              showAnimatedDialog2(
                context,
                animationController!,
                animation!,
                'Choose Your Payment Option',
                'You can either pay using cash or opt for gold as your preferred payment method. Select an option to proceed',
                [
                  SizedBox(height: 30.h),
                  CustomOutlinedBtn(
                    borderRadius: 12.sp,
                    borderColor: UIColor.gold,
                    padH: 12.w,
                    padV: 12.h,
                    onTapped: () {
                      selectedValue = 'Gold';
                      Navigator.pop(context);
                      navigateToDeliveryDetails();
                    },
                    btnTextColor: UIColor.gold,
                    btnText: 'Gold to Gold',
                  ),
                  SizedBox(height: 10.h),
                  CustomOutlinedBtn(
                    borderRadius: 12.sp,
                    borderColor: UIColor.gold,
                    padH: 12.w,
                    padV: 12.h,
                    onTapped: () {
                      selectedValue = 'Cash';
                      Navigator.pop(context);
                      navigateToDeliveryDetails(
                        paymentMethod: context
                            .read<OrderHistoryViewModel>()
                            .cashPricingModel
                            ?.data
                            .methodType,
                        pricingOption: context
                            .read<OrderHistoryViewModel>()
                            .cashPricingModel
                            ?.data
                            .pricingType,
                        amount: context
                            .read<OrderHistoryViewModel>()
                            .cashPricingModel
                            ?.data
                            .value
                            .toString()
                      );
                    },
                    btnTextColor: UIColor.gold,
                    btnText: 'Cash',
                  ),
                ]
              );
            },
          ),
        ),
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
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 350.h,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    itemCount: widget.prodImg.length,
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22.sp),
                          child: CachedNetworkImage(
                            imageUrl: widget.prodImg[index],
                            height: 400.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  children: List.generate(
                      widget.prodImg.length,
                      (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                pageController.jumpToPage(index);
                              });
                            },
                            child: Container(
                                height: 50.h,
                                width: 50.w,
                                margin: EdgeInsets.only(right: 15.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: currentIndex == index
                                            ? UIColor.gold
                                            : UIColor.white),
                                    borderRadius: BorderRadius.circular(12.sp)),
                                child: CachedNetworkImage(
                                  imageUrl: widget.prodImg[index],
                                  fit: BoxFit.cover,
                                )),
                          )),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  widget.title,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: UIColor.gold,
                      fontFamily: 'Familiar',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: CustomOutlinedBtn(
                          btnText: 'Description',
                          btnTextColor:
                              page2Index == 0 ? UIColor.white : UIColor.gold,
                          bgColor: page2Index == 0
                              ? UIColor.gold
                              : Colors.transparent,
                          borderColor: UIColor.gold,
                          borderRadius: 12.sp,
                          height: 35.h,
                          iconColor: UIColor.gold,
                          padH: 14.w,
                          padV: 5.h,
                          onTapped: () {
                            setState(() {
                              page2Index = 0;
                            });
                          }),
                    ),
                    SizedBox(
                      width: 40.w,
                    ),
                    Flexible(
                      child: CustomOutlinedBtn(
                          btnText: 'Specification',
                          btnTextColor:
                              page2Index == 1 ? UIColor.white : UIColor.gold,
                          borderColor: UIColor.gold,
                          borderRadius: 12.sp,
                          bgColor: page2Index == 1
                              ? UIColor.gold
                              : Colors.transparent,
                          height: 35.h,
                          padH: 14.w,
                          padV: 5.h,
                          onTapped: () {
                            setState(() {
                              page2Index = 1;
                            });
                          }),
                    )
                  ],
                ),
                page2Index == 0
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          widget.desc,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 15.sp,
                            fontFamily: 'Familiar',
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Purity : ',
                                  style: TextStyle(
                                    color: UIColor.gold,
                                    fontFamily: 'Familiar',
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Text(
                                  widget.purity.toString(),
                                  style: TextStyle(
                                    color: UIColor.gold,
                                    fontFamily: 'Familiar',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Weight : ',
                                  style: TextStyle(
                                      color: UIColor.gold,
                                      fontFamily: 'Familiar',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.weight.toString(),
                                  style: TextStyle(
                                      color: UIColor.gold,
                                      fontFamily: 'Familiar',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              widget.stock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _marketDataSubscription?.cancel();   
    animationController?.dispose();
    super.dispose();
  }
}