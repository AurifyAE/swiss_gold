// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';

import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_alert.dart';
import 'package:swiss_gold/core/utils/widgets/custom_card.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart'; 
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/views/delivery/delivery_view.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/products/product_view.dart';  

import '../../core/services/server_provider.dart';
import '../../core/utils/calculations/total_amount_calculation.dart'; 

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  Map<int, int> productQuantities = {};
  List<Map<String, dynamic>> bookingData = [];
  AnimationController? animationController;
  Animation<double>? animation;
  String selectedValue = '';
  DateTime selectedDate = DateTime.now();
  final FocusNode _pageFocusNode = FocusNode();
  bool _initialFetchDone = false;

// void navigateToDeliveryDetails(
//     {String? paymentMethod, String? pricingOption, String? amount}) {
//   // Store current state before navigation
//   final Map<int, int> previousQuantities = Map<int, int>.from(productQuantities);
//   final List<Map<String, dynamic>> previousBookingData = List<Map<String, dynamic>>.from(bookingData);
  
//   final effectivePaymentMethod =
//       selectedValue != 'Gold' ? (paymentMethod ?? 'Cash') : 'Gold';

//   Map<String, dynamic> finalPayload = {
//     "bookingData": bookingData,
//     "paymentMethod": effectivePaymentMethod,
//     if (selectedValue != 'Gold' && pricingOption != null)
//       "pricingOption": pricingOption,
//     "deliveryDate": selectedDate.toString().split(' ')[0]
//   };

//   if (selectedValue == 'Gold' &&
//       pricingOption == 'Premium' &&
//       amount != null) {
//     finalPayload['premium'] = amount;
//   }
//   if (selectedValue != 'Gold' &&
//       pricingOption == 'Discount' &&
//       amount != null) {
//     finalPayload['discount'] = amount;
//   }

//   // Ensure the ViewModel has the current state before navigation
//   final productViewModel = context.read<ProductViewModel>();
//   productViewModel.setQuantities(Map<int, int>.from(productQuantities));

//   // Use Navigator.push with awaiting the result
//   Navigator.push<Map<String, dynamic>>(
//     context,
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => 
//         DeliveryDetailsView(
//           orderData: finalPayload,
//           onConfirm: (deliveryDetails) {
//             processOrder(finalPayload);
//           },
//         ),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//         return SlideTransition(position: offsetAnimation, child: child);
//       },
//     ),
//   ).then((result) {
//     // Handle the result from DeliveryDetailsView
//     if (result != null) {
//       log('Returned from delivery page with result: $result');
      
//       // If order was successful, reset state
//       if (result['orderSuccess'] == true) {
//         setState(() {
//           selectedValue = '';
//           bookingData.clear();
//           productQuantities.clear();
//         });
        
//         // Clear ViewModel state too
//         productViewModel.clearQuantities();
        
//         log('Order was successful, quantities reset');
//       } 
//       // If explicitly cancelled or failed, restore the previous state
//       else {
//         log('Order was cancelled or failed, restoring previous quantities');
//         setState(() {
//           productQuantities = Map<int, int>.from(previousQuantities);
//           bookingData = List<Map<String, dynamic>>.from(previousBookingData);
//         });
        
//         // Restore ViewModel state too
//         productViewModel.setQuantities(Map<int, int>.from(previousQuantities));
//         productViewModel.getTotalQuantity(Map<int, int>.from(previousQuantities));
//       }
//     } else {
//       // If result is null (back button press), restore previous state
//       log('Navigation returned null (likely back button), restoring previous state');
//       setState(() {
//         productQuantities = Map<int, int>.from(previousQuantities);
//         bookingData = List<Map<String, dynamic>>.from(previousBookingData);
//       });
      
//       // Restore ViewModel state too
//       productViewModel.setQuantities(Map<int, int>.from(previousQuantities));
//       productViewModel.getTotalQuantity(Map<int, int>.from(previousQuantities));
//     }
//   });
// }

void navigateToDeliveryDetails(
    {String? paymentMethod, String? pricingOption, String? amount}) {
  // Store current state before navigation
  final Map<int, int> previousQuantities = Map<int, int>.from(productQuantities);
  final List<Map<String, dynamic>> previousBookingData = List<Map<String, dynamic>>.from(bookingData);
  
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

  // Ensure the ViewModel has the current state before navigation
  final productViewModel = context.read<ProductViewModel>();
  productViewModel.setQuantities(Map<int, int>.from(productQuantities));

  // Use Navigator.push with awaiting the result
  Navigator.push<Map<String, dynamic>>(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => 
        DeliveryDetailsView(
          orderData: finalPayload,
          onConfirm: (deliveryDetails) {
            // This callback is called from DeliveryDetailsView
            log('Order confirmed with details: $deliveryDetails');
          },
        ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  ).then((result) {
  log('Navigation returned from DeliveryDetailsView with result: $result');
  
  // Handle successful order completion
  if (result != null && result['orderSuccess'] == true) {
    log('Order was successful, clearing all quantities and state');
    
    // Clear local state
    setState(() {
      selectedValue = '';
      bookingData.clear();
      productQuantities.clear();
    });
    
    // Clear ViewModel state and refresh total quantity
    final productViewModel = context.read<ProductViewModel>();
    productViewModel.clearQuantities();
    productViewModel.getTotalQuantity({}); // Reset total to 0
    
    // Show success message
    customSnackBar(
      bgColor: UIColor.gold,
      titleColor: UIColor.white,
      width: 250.w,
      context: context,
      title: result['message'] ?? 'Order placed successfully'
    );
    
    log('✅ All quantities and state cleared after successful order');
  } 
  // Handle explicit cancellation
  else if (result != null && result['cancelled'] == true) {
    log('Order was explicitly cancelled, restoring previous state');
    setState(() {
      productQuantities = Map<int, int>.from(previousQuantities);
      bookingData = List<Map<String, dynamic>>.from(previousBookingData);
    });
    
    productViewModel.setQuantities(Map<int, int>.from(previousQuantities));
    productViewModel.getTotalQuantity(Map<int, int>.from(previousQuantities));
  }
  // Handle back button or other navigation without explicit result
  else if (result == null) {
    log('Navigation returned null, restoring previous state');
    setState(() {
      productQuantities = Map<int, int>.from(previousQuantities);
      bookingData = List<Map<String, dynamic>>.from(previousBookingData);
    });
    
    productViewModel.setQuantities(Map<int, int>.from(previousQuantities));
    productViewModel.getTotalQuantity(Map<int, int>.from(previousQuantities));
  }
});

}

// Add this method to ProductViewModel class



@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // Synchronize with ViewModel when dependencies change (like after navigation)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _syncQuantitiesFromViewModel();
  });
}

  void processOrder(Map<String, dynamic> finalPayload) {

    if (finalPayload.containsKey("success") &&
        finalPayload["success"] == true) {
      setState(() {
        selectedValue = '';
        bookingData.clear();
        productQuantities.clear();
      });

      context.read<ProductViewModel>().clearQuantities();
    } else {}
  }

  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryViewModel>().getCashPricing('Cash');
    context.read<OrderHistoryViewModel>().getBankPricing('Bank');

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );

    scrollController.addListener(
      () {
        if (scrollController.position.atEdge) {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            final model = context.read<ProductViewModel>();

            if (!model.isLoading && model.hasMoreData) {
              currentPage++;
              _loadMoreProducts();
            }
          }
        }
      },
    );

    _pageFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialFetchDone) {
        _syncQuantitiesFromViewModel();

        if (context.read<ProductViewModel>().productList.isEmpty) {
          context.read<ProductViewModel>().fetchProducts();
        }
        _initialFetchDone = true;
      }
    });
  }

  void _onFocusChange() {
    if (_pageFocusNode.hasFocus) {
      _syncQuantitiesFromViewModel();
    }
  }

void _syncQuantitiesFromViewModel() {
  final viewModel = context.read<ProductViewModel>();
  
  // Only update if ViewModel has quantities
  if (viewModel.productQuantities.isNotEmpty) {
    setState(() {
      productQuantities = Map<int, int>.from(viewModel.productQuantities);
      _updateBookingData();
    });
    
    // Make sure total quantity is updated too
    viewModel.getTotalQuantity(productQuantities);
  }
}

  void _updateBookingData() {
    bookingData.clear();

    final productList = context.read<ProductViewModel>().productList;
    productQuantities.forEach((index, quantity) {
      if (index < productList.length && quantity > 0) {
        final product = productList[index];
        bookingData.add({
          "productId": product.pId,
          "quantity": quantity,
        });
      }
    });
  }

  void _loadMoreProducts() {
    final viewModel = context.read<ProductViewModel>();
    final String adminId = viewModel.adminId ?? '';
    final String categoryId = viewModel.categoryId ?? '';
    viewModel.fetchProducts(adminId, categoryId, currentPage.toString());
  }

  void addToBookingData(int index, String pId) {
    int quantity = productQuantities[index] ?? 1;

    int existingIndex =
        bookingData.indexWhere((item) => item["productId"] == pId);

    if (existingIndex != -1) {
      bookingData[existingIndex]["quantity"] =
          (bookingData[existingIndex]["quantity"] ?? 0) + 1;
    } else {
      bookingData.add({
        "productId": pId,
        "quantity": quantity,
      });
    }
  }

  void removeFromBookingData(int index, String pId) {
    int existingIndex =
        bookingData.indexWhere((item) => item["productId"] == pId);

    if (existingIndex != -1) {
      if (bookingData[existingIndex]["quantity"] > 1) {
        bookingData[existingIndex]["quantity"] =
            (bookingData[existingIndex]["quantity"] ?? 0) - 1;
      } else {
        bookingData.removeAt(existingIndex);
      }
    }
  }

  void incrementQuantity(int index) {
    if (index >= context.read<ProductViewModel>().productList.length) {
      log('Invalid index: $index for product list');
      return;
    }

    final product = context.read<ProductViewModel>().productList[index];

    final String productId = product.pId;
    log('Incrementing quantity for product: $productId at index: $index');

    setState(() {
      if (productQuantities[index] != null) {
        productQuantities[index] = productQuantities[index]! + 1;
        log('Updated quantity: ${productQuantities[index]} for index: $index');
      } else {
        productQuantities[index] = 1;
        log('Initial quantity set to 1 for index: $index');
      }

      context
          .read<ProductViewModel>()
          .getTotalQuantity(Map<int, int>.from(productQuantities));

      addToBookingData(index, product.pId);
    });

    if (context.read<ProductViewModel>().isGuest == false) {
      context
          .read<CartViewModel>()
          .incrementQuantity({'pId': productId}, index: index).then((result) {
        if (result != null && result.success == true) {
          log('Cart incremented for product: $productId with quantity: ${productQuantities[index]}');
        } else {
          log('Failed to increment cart: ${result?.message ?? "Unknown error"}');
        }
      }).catchError((error) {
        log('Error incrementing cart: $error');
      });
    } else {
      context.read<CartViewModel>().incrementQuantity(
          {'pId': productId, 'userId': 'gyu123'},
          index: index).then((result) {
        if (result != null && result.success == true) {
          log('Cart incremented for guest user with admin ID "gyu123" for product: $productId with quantity: ${productQuantities[index]}');
        } else {
          log('Failed to increment cart for guest user: ${result?.message ?? "Unknown error"}');
        }
      }).catchError((error) {
        log('Error incrementing cart for guest user: $error');
      });
      log('User in guest mode, cart updated on server with admin ID: gyu123');
    }
  }

  void decrementQuantity(int index) {
    if (index >= context.read<ProductViewModel>().productList.length) {
      log('Invalid index: $index for product list');
      return;
    }

    final product = context.read<ProductViewModel>().productList[index];

    if (productQuantities[index] == null || productQuantities[index]! <= 0) {
      log('Quantity is already 0 or null for index: $index');
      return;
    }

    final String productId = product.pId;
    log('Decrementing quantity for product: $productId at index: $index');

    setState(() {
      productQuantities[index] = productQuantities[index]! - 1;
      log('Updated quantity: ${productQuantities[index]} for index: $index');

      if (productQuantities[index] == 0) {
        productQuantities.remove(index);
        log('Removed index: $index from productQuantities as quantity is 0');
      }

      context
          .read<ProductViewModel>()
          .getTotalQuantity(Map<int, int>.from(productQuantities));

      removeFromBookingData(index, product.pId);
    });

    if (context.read<ProductViewModel>().isGuest == false) {
      context.read<CartViewModel>().decrementQuantity({
        'pId': productId,
        'quantity': productQuantities[index] ?? 0
      }).then((response) {
        if (response?.success == true) {
          log('Cart decremented for product: $productId with quantity: ${productQuantities[index] ?? 0}');
        } else {
          log('Failed to decrement cart: ${response?.message}');
        }
      }).catchError((error) {
        log('Error decrementing cart: $error');
      });
    } else {
      log('User in guest mode, cart not updated on server');
    }
  }



 @override
Widget build(BuildContext context) {
  final goldRateProvider = Provider.of<GoldRateProvider>(context);
  return Focus(
    focusNode: _pageFocusNode,
    child: Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Consumer<ProductViewModel>(
              builder: (context, model, child) => Text(
                'Total Quantity: ${model.totalQuantity}',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Spacer(),
            Flexible(
              child: CustomOutlinedBtn(
                btnTextColor: UIColor.gold,
                height: 40.h,
                borderRadius: 12.sp,
                borderColor: UIColor.gold,
                padH: 5.w,
                padV: 5.h,
                onTapped: () {
                  if (bookingData.isNotEmpty) {
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
                                  .toString(),
                            );
                            selectedValue = '';
                            productQuantities.clear();
                          },
                          btnTextColor: UIColor.gold,
                          btnText: 'Cash',
                        ),
                      ],
                    );
                  } else {
                    customSnackBar(
                      bgColor: UIColor.gold,
                      titleColor: UIColor.white,
                      width: 180.w,
                      context: context,
                      title: 'Please select products',
                    );
                  }
                },
                btnText: 'Place order',
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sticky Gold Rate Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 16.w,
              right: 16.w,
              bottom: 8.h,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Consumer<GoldRateProvider>(
              builder: (context, goldRateProvider, child) {
                if (goldRateProvider.isLoading) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: UIColor.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: UIColor.gold.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14.w,
                          height: 14.h,
                          child: CircularProgressIndicator(
                            color: UIColor.gold,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Loading rate...',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                } 
                
                if (goldRateProvider.goldData == null || !goldRateProvider.isConnected) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.signal_wifi_off, color: Colors.red, size: 14.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Rate unavailable',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Familiar',
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => goldRateProvider.refreshGoldData(),
                          child: Icon(Icons.refresh, color: Colors.red, size: 14.sp),
                        ),
                      ],
                    ),
                  );
                }

               final goldData = goldRateProvider.goldData!;
// Change from using bid to using the calculated asking price
final displayPrice = goldRateProvider.getDisplayPrice(); // This will show asking price
final high = goldData['high']?.toStringAsFixed(2) ?? 'N/A';
final low = goldData['low']?.toStringAsFixed(2) ?? 'N/A';

return Container(
  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
  decoration: BoxDecoration(
    color: UIColor.gold.withOpacity(0.08),
    borderRadius: BorderRadius.circular(8.sp),
    border: Border.all(color: UIColor.gold, width: 2),
  ),
  child: Row(
    children: [
      // Live indicator
      Container(
        width: 6.w,
        height: 6.h,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: 8.w),
      
      // Main rate - now showing asking price
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gold Rate (Ask)', // Updated label to indicate it's ask price
              style: TextStyle(
                color: UIColor.gold.withOpacity(0.7),
                fontFamily: 'Familiar',
                fontSize: 10.sp,
              ),
            ),
            Text(
              '\$$displayPrice', // Now shows calculated asking price
              style: TextStyle(
                color: UIColor.gold,
                fontFamily: 'Familiar',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      
      // High/Low compact
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_up, color: Colors.green, size: 12.sp),
              Text(
                '\$$high',
                style: TextStyle(
                  color: Colors.green,
                  fontFamily: 'Familiar',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_down, color: Colors.red, size: 12.sp),
              Text(
                '\$$low',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Familiar',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      
      SizedBox(width: 8.w),
      
      // Refresh button
      GestureDetector(
        onTap: () => goldRateProvider.refreshGoldData(),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Icon(
            Icons.refresh,
            color: UIColor.gold.withOpacity(0.7),
            size: 14.sp,
          ),
        ),
      ),
    ],
  ),
); 
              },
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Colors.transparent, 
              color: UIColor.gold,
              onRefresh: () async {
                currentPage = 1;
                final model = context.read<ProductViewModel>(); 
                model.clearProducts();
                await model.refreshUserStatus();
                model.getSpotRate();
                _syncQuantitiesFromViewModel();
                // Refresh gold rate data
                await goldRateProvider.refreshGoldData();
                return Future.value();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Consumer<ProductViewModel>(
                    builder: (context, model, child) {
                      if (model.state == ViewState.loading) {
                        return Center(
                          child: Lottie.asset(ImageAssets.loading),
                        );
                      } else if (model.productList.isEmpty) {
                        return Center(
                          heightFactor: 2.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(ImageAssets.noProducts),
                              SizedBox(height: 10.h),
                              Text(
                                "Sorry no products found\ntry some other category",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontSize: 20.sp,
                                  fontFamily: 'Familiar',
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        void updateQuantityDirectly(int index, int newQuantity) {
                          if (index >= model.productList.length) {
                            log('Invalid index: $index for product list');
                            return;
                          }
                          final product = model.productList[index];
                          final String productId = product.pId;
                          final int oldQuantity = productQuantities[index] ?? 0;
                          final int difference = newQuantity - oldQuantity;
                          log('Updating quantity directly for product: $productId at index: $index from $oldQuantity to $newQuantity');
                          setState(() {
                            if (newQuantity > 0) {
                              productQuantities[index] = newQuantity;
                              log('Updated quantity: $newQuantity for index: $index');
                            } else {
                              productQuantities.remove(index);
                              log('Removed index: $index from productQuantities as quantity is 0');
                            }
                            model.getTotalQuantity(Map<int, int>.from(productQuantities));
                            if (difference > 0) {
                              for (int i = 0; i < difference; i++) {
                                addToBookingData(index, product.pId);
                              }
                            } else if (difference < 0) {
                              for (int i = 0; i < difference.abs(); i++) {
                                removeFromBookingData(index, product.pId);
                              }
                            }
                          });
                          if (model.isGuest == false) {
                            context.read<CartViewModel>().updateCartQuantity(productId, newQuantity).then((result) {
                              if (result != null && result.success == true) {
                                log('Cart updated for product: $productId with quantity: $newQuantity');
                                if (bookingData.isNotEmpty && newQuantity > 0) {}
                              } else {
                                log('Failed to update cart: ${result?.message ?? "Unknown error"}');
                              }
                            }).catchError((error) {
                              log('Error updating cart: $error');
                            });
                          } else {
                            log('User in guest mode, cart not updated on server');
                          }
                        }
                        
                        return Column(
                          children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              key: PageStorageKey('productKey'),
                              shrinkWrap: true,
                              itemCount: model.productList.length,
                              itemBuilder: (context, index) {
                                final product = model.productList[index];
                                Map<String, double> pricing = calculateProductPricing(
                                  product: product,
                                  quantity: 1,
                                  goldRateProvider: goldRateProvider,
                                  calculationContext: "PRODUCT_DETAILS Item #$index ",
                                );
                                final String productId = product.pId;
                                final String imageUrl = product.prodImgs.isNotEmpty
                                    ? product.prodImgs[0].url
                                    : 'https://via.placeholder.com/150';
                                final String title = product.title;
                                final int quantity = productQuantities[index] ?? 0;
                                final price = pricing['basePrice']!;
                                final String productType = product.type ?? 'Unknown';
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: CustomCard(
                                    onIncrement: () => incrementQuantity(index),
                                    onDecrement: () => decrementQuantity(index),
                                    onQuantityEntered: (newQuantity) => updateQuantityDirectly(index, newQuantity),
                                    onAddToCart: () {
                                      if (model.isGuest == false) {
                                        context.read<CartViewModel>().updateQuantityFromHome(productId, {
                                          'quantity': productQuantities[index] ?? 1,
                                        }).then((response) {
                                          if (response?.success == true) {
                                            setState(() {
                                              productQuantities.remove(index);
                                            });
                                            model.getTotalQuantity(Map<int, int>.from(productQuantities));
                                          }
                                          customSnackBar(
                                            context: context,
                                            width: 250.w,
                                            bgColor: UIColor.gold,
                                            title: response?.message?.toString() ?? 'Action completed',
                                          );
                                        });
                                      } else {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginView()),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    prodImg: imageUrl,
                                    title: title,
                                    quantity: quantity,
                                    price: price,
                                    subTitle: productType,
                                    onTap: () {
                                      navigateWithAnimationTo(
                                        context,
                                        ProductView(
                                          prodImg: product.prodImgs.map((e) => e.url).toList(),
                                          title: title,
                                          pId: productId,
                                          desc: product.desc,
                                          type: productType,
                                          stock: product.stock,
                                          purity: product.purity,
                                          weight: product.weight,
                                          makingCharge: product.makingCharge,
                                        ),
                                        0,
                                        1,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            if (model.state == ViewState.loadingMore)
                              Padding(
                                padding: EdgeInsets.only(top: 20.h),
                                child: Center(
                                  child: CircularProgressIndicator(color: UIColor.gold),
                                ),
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ), 
  );  
}

  @override
  void dispose() {
    _pageFocusNode.removeListener(_onFocusChange);
    _pageFocusNode.dispose();
    animationController?.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
