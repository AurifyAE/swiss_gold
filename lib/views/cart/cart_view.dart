// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:swiss_gold/core/services/product_service.dart';
// import 'package:swiss_gold/core/utils/colors.dart';
// import 'package:swiss_gold/core/utils/enum/view_state.dart';
// import 'package:swiss_gold/core/utils/image_assets.dart';
// import 'package:swiss_gold/core/utils/navigate.dart';
// import 'package:swiss_gold/core/utils/widgets/custom_alert.dart';
// import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
// import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
// import 'package:swiss_gold/core/view_models/cart_view_model.dart';
// import 'package:swiss_gold/core/view_models/product_view_model.dart';
// import 'package:swiss_gold/views/cart/widgets/cart_card.dart';
// import 'package:swiss_gold/views/login/login_view.dart';
// import 'package:swiss_gold/views/products/product_view.dart';

// class CartView extends StatefulWidget {
//   const CartView({super.key});

//   @override
//   State<CartView> createState() => _CartViewState();
// }

// class _CartViewState extends State<CartView> with TickerProviderStateMixin {
//   int? selectedProdIndex;
//   List bookingData = [];
//   double goldBid = 0;
//   double goldPrice = 0;
//   double totalPrice = 0;
//   AnimationController? animationController;
//   Animation<double>? animation;

//   @override
//   void initState() {
//     super.initState();

//     context.read<ProductViewModel>().getSpotRate();
//     ProductService.marketDataStream.listen((marketData) {
//       String symbol = marketData['symbol'].toString().toLowerCase();

//       if (mounted) {
//         // Check if the widget is still mounted
//         if (symbol == 'gold') {
//           setState(() {
//             goldBid = (marketData['bid'] is int)
//                 ? (marketData['bid'] as int).toDouble()
//                 : marketData['bid'];
//           });
//         }
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final model = context.read<CartViewModel>();
//       Provider.of<ProductViewModel>(context, listen: false).getRealtimePrices();
//       model.checkGuestMode().then((_) {
//         if (model.isGuest == false) {
//           model.getCart();
//         }
//       });
//     });
//     animationController = AnimationController(
//       vsync: this,
//       duration:
//           const Duration(milliseconds: 300), // Adjust duration for animation
//     );
//     animation = CurvedAnimation(
//       parent: animationController!,
//       curve: Curves.easeInOut,
//     );
//   }

//   String selectedValue = '';
//   DateTime? selectedDate = DateTime.now();

//   Future<void> selectDate() async {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(builder: (context, setState) {
//             return Theme(
//               data: Theme.of(context).copyWith(
//                 primaryColor: UIColor.gold,
//                 colorScheme: ColorScheme.dark(
//                   onPrimary: UIColor.black, // header text color
//                   onSurface: UIColor.gold, // body text color
//                 ),
//               ),
//               child: Material(
//                 child: Scaffold(
//                   body: Container(
//                     color: UIColor.black,
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           height: 20.h,
//                         ),
//                         Text(
//                           'Select delivery date ',
//                           style: TextStyle(
//                               color: UIColor.gold,
//                               fontFamily: 'Familiar',
//                               fontSize: 17.sp,
//                               fontWeight: FontWeight.normal),
//                         ),
//                         SizedBox(
//                           height: 50.h,
//                         ),
//                         CalendarDatePicker(
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime.now(),
//                             lastDate: DateTime(2100),
//                             onDateChanged: (date) {
//                               setState(() {
//                                 selectedDate = date;
//                               });
//                             }),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 22.w),
//                           child: Row(
//                             children: [
//                               Text(
//                                 'Selected date : ',
//                                 style: TextStyle(
//                                     color: UIColor.gold,
//                                     fontFamily: 'Familiar',
//                                     fontSize: 17.sp,
//                                     fontWeight: FontWeight.normal),
//                               ),
//                               Text(
//                                 selectedDate.toString().split(' ')[0],
//                                 style: TextStyle(
//                                     color: UIColor.gold,
//                                     fontFamily: 'Familiar',
//                                     fontSize: 17.sp,
//                                     fontWeight: FontWeight.normal),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 40.h,
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 22.w),
//                           child: Row(
//                             children: [
//                               CustomOutlinedBtn(
//                                 borderRadius: 12.sp,
//                                 width: 100.w,
//                                 fontSize: 18.sp,
//                                 borderColor: UIColor.gold,
//                                 padH: 4.w,
//                                 padV: 8.h,
//                                 onTapped: () {
//                                   if (selectedDate != null) {
//                                     final cartModel =
//                                         context.read<CartViewModel>();
//                                     final model =
//                                         context.read<ProductViewModel>();

//                                     List<Map<String, dynamic>> bookingData = [];

//                                     for (var item in cartModel.cartList) {
//                                       // Calculate price based on product type
//                                       if (item.productDetails.type
//                                               .toLowerCase() ==
//                                           'gold') {
//                                         goldPrice = (((goldBid +
//                                                         model.goldSpotRate!) /
//                                                     31.103) *
//                                                 3.674 *
//                                                 item.productDetails.weight *
//                                                 item.productDetails.purity /
//                                                 pow(
//                                                     10,
//                                                     item.productDetails.purity
//                                                         .toString()
//                                                         .length) +
//                                             item.productDetails.makingCharge);
//                                       }

//                                       // Add data to bookingData
//                                       bookingData.add({
//                                         "productId": item.productId,
//                                         "fixedPrice": goldPrice
//                                       });
//                                     }

//                                     Map<String, dynamic> finalPayload = {
//                                       "bookingData": bookingData,
//                                     };

//                                     model
//                                         .fixPrice(finalPayload)
//                                         .then((response) {
//                                       if (response!.success == true) {
//                                         context
//                                             .read<ProductViewModel>()
//                                             .bookProducts({
//                                           'paymentMethod': selectedValue,
//                                           'deliveryDate': selectedDate
//                                               .toString()
//                                               .split(' ')[0]
//                                         }).then((response) {
//                                           if (response!.success == true) {
//                                             Navigator.pop(context);
//                                             selectedDate = null;
//                                             selectedValue = '';
//                                             customSnackBar(
//                                                 bgColor: UIColor.gold,
//                                                 titleColor: UIColor.white,
//                                                 width: 130.w,
//                                                 context: context,
//                                                 title: 'Booking success');
//                                             context
//                                                 .read<CartViewModel>()
//                                                 .getCart();
//                                           } else {
//                                             customSnackBar(
//                                                 bgColor: UIColor.gold,
//                                                 titleColor: UIColor.white,
//                                                 width: 130.w,
//                                                 context: context,
//                                                 title: 'Booking failed');
//                                           }
//                                         });
//                                       }
//                                     });
//                                   } else {
//                                     customSnackBar(
//                                         context: context,
//                                         bgColor: UIColor.gold,
//                                         titleColor: UIColor.white,
//                                         width: 200.w,
//                                         title: 'Please choose a delivery date');
//                                   }
//                                 },
//                                 btnTextColor: UIColor.gold,
//                                 btnText: 'Confirm',
//                               ),
//                               Spacer(),
//                               CustomOutlinedBtn(
//                                   borderRadius: 12.sp,
//                                   fontSize: 18.sp,
//                                   borderColor: UIColor.gold,
//                                   padH: 4.w,
//                                   padV: 8.h,
//                                   width: 100.w,
//                                   btnText: 'Cancel',
//                                   btnTextColor: UIColor.gold,
//                                   onTapped: () {
//                                     Navigator.pop(context);
//                                   })
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           });
//         });

//     // selectedDate = await showDatePicker(
//     //     builder: (context, child) {
//     //       return Theme(
//     //         data: Theme.of(context).copyWith(
//     //           primaryColor: UIColor.gold,
//     //           colorScheme: ColorScheme.dark(
//     //             onPrimary: UIColor.black, // header text color
//     //             onSurface: UIColor.gold, // body text color
//     //           ),
//     //         ),
//     //         child: Material(
//     //           child: Container(
//     //             color: UIColor.black,
//     //             child: Column(
//     //               mainAxisAlignment: MainAxisAlignment.center,
//     //               children: [
//     //                 child!,
//     //               ],
//     //             ),
//     //           ),
//     //         ),
//     //       );
//     //     },
//     //     context: context,
//     //     initialDate: DateTime.now(),
//     //     firstDate: DateTime.now(),
//     //     lastDate: DateTime(2100)

//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//         child: Consumer<CartViewModel>(
//           builder: (context, model, child) {
//             if (model.cartModel == null || model.cartList.isEmpty) {
//               return SizedBox.shrink();
//             } else {
              
//               totalPrice = 0;

//               for (var cartItem in model.cartList) {
//                 if (cartItem.productDetails.type.toLowerCase() == 'gold') {
//                   goldPrice = ((((goldBid +
//                                       context
//                                           .read<ProductViewModel>()
//                                           .goldSpotRate!) /
//                                   31.103) *
//                               3.674 *
//                               cartItem.productDetails.weight *
//                               cartItem.productDetails.purity /
//                               pow(
//                                   10,
//                                   cartItem.productDetails.purity
//                                       .toString()
//                                       .length) +
//                           cartItem.productDetails.makingCharge) *
//                       cartItem.quantity);
//                 }

//                 totalPrice += goldPrice;
//               }

//               return CustomOutlinedBtn(
//                 borderRadius: 12.sp,
//                 borderColor: UIColor.gold,
                
//                 padH: 12.w,
//                 padV: 12.h,
//                 btnTextColor: UIColor.gold,
//                 onTapped: () {
//                  showAnimatedDialog(
//                       context,
//                       animationController!,
//                       animation!,
//                       'Choose Your Payment Option',
//                       'You can either pay using cash or opt for gold as your preferred payment method. Select an option to proceed',
//                       [
//                         Flexible(
//                             child: CustomOutlinedBtn(
//                           borderRadius: 12.sp,
//                           borderColor: UIColor.gold,
//                           padH: 12.w,
//                           padV: 12.h,
//                           onTapped: () {
//                             selectedValue = 'Gold';
//                             Navigator.pop(context);
              
//                             selectDate();
//                           },
//                           btnTextColor: UIColor.gold,
//                           btnText: 'Gold',
//                         )),
//                         Spacer(),
//                         Flexible(
//                             child: CustomOutlinedBtn(
//                           borderRadius: 12.sp,
//                           borderColor: UIColor.gold,
//                           padH: 12.w,
//                           padV: 12.h,
//                           btnTextColor: UIColor.gold,
//                           onTapped: () {
//                             selectedValue = 'Cash';
//                             Navigator.pop(context);
//                             selectDate();
//                           },
//                           btnText: 'Cash',
//                         )),
//                       ]);
//                 },
//                 btnText: 'Order now',
//               );

             
//             }
//           },
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//         child: Consumer<CartViewModel>(
//           builder: (context, model, child) {
//             if (model.state == ViewState.loading) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: UIColor.gold,
//                 ),
//               );
//             } else if (model.isGuest == true) {
//               return Center(
//                 child: CustomOutlinedBtn(
//                   borderRadius: 22.sp,
//                   borderColor: UIColor.gold,
//                   padH: 10.w,
//                   padV: 10.h,
//                   width: 200.w,
//                   btnText: 'Login',
//                   btnTextColor: UIColor.gold,
//                   fontSize: 22.sp,
//                   onTapped: () {
//                     navigateTo(context, LoginView());
//                   },
//                 ),
//               );
//             } else if (model.cartModel == null ||
//                 model.cartModel!.data.isEmpty) {
//               return Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       ImageAssets.emptycart,
//                     ),
//                     SizedBox(height: 10.h),
//                     Text(
//                       "Your Swiss Gold Cart is empty",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: UIColor.gold, fontSize: 20.sp),
//                     )
//                   ],
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 physics: BouncingScrollPhysics(),
//                 itemCount: model.cartList.length,
//                 itemBuilder: (context, index) {
//                   return Consumer<CartViewModel>(
//                       builder: (context, model, child) {
//                     goldPrice = ((((goldBid +
//                                         context
//                                             .read<ProductViewModel>()
//                                             .goldSpotRate!) /
//                                     31.103) *
//                                 3.674 *
//                                 model.cartList[index].productDetails.weight *
//                                 model.cartList[index].productDetails.purity /
//                                 pow(
//                                     10,
//                                     model.cartList[index].productDetails.purity
//                                         .toString()
//                                         .length) +
//                             model.cartList[index].productDetails.makingCharge) *
//                         model.cartList[index].quantity);

//                     return GestureDetector(
//                       onTap: () {
//                         navigateWithAnimationTo(
//                             context,
//                             ProductView(
//                                 prodImg:
//                                     model.cartList[index].productDetails.images,
//                                 makingCharge: model.cartList[index]
//                                     .productDetails.makingCharge,
//                                 title:
//                                     model.cartList[index].productDetails.title,
//                                 desc: model
//                                     .cartList[index].productDetails.description,
//                                 pId: model.cartList[index].productId,
//                                 purity:
//                                     model.cartList[index].productDetails.purity,
//                                 weight:
//                                     model.cartList[index].productDetails.weight,
//                                 stock: true,
//                                 type:
//                                     model.cartList[index].productDetails.type),
//                             1,
//                             0);
//                       },
//                       child: CartCard(
//                         prodImg: model.cartList[index].productDetails.images[0],
//                         type: model.cartList[index].productDetails.type,
//                         prodTitle: model.cartList[index].productDetails.title,
//                         price: model.cartList[index].productDetails.type
//                                     .toLowerCase() ==
//                                 'gold'
//                             ? 'AED ${goldPrice.toStringAsFixed(2)}'
//                             : '0.0',
//                         state: index == selectedProdIndex &&
//                             (model.quantityState == ViewState.loading),
//                         onDecrementTapped: () {
//                           model.decrementQuantity(
//                               {'pId': model.cartList[index].productId},
//                             index:  index).then((_) {
//                             model.updatePrice();
//                           });
//                           selectedProdIndex = index;
//                         },
//                         onIncrementTapped: () {
//                           selectedProdIndex = index;

//                           model.incrementQuantity(
//                               {'pId': model.cartList[index].productId},
//                             index:  index).then((_) {
//                             model.updatePrice();
//                           });
//                         },
//                         quantity: model.cartList[index].quantity,
//                         onRemoveTapped: () {
//                           model.deleteFromCart({
//                             'pId': model.cartList[index].productId
//                           }).then((response) {
//                             if (response!.success == true) {
//                               model.cartList.removeAt(index);
//                               model.updatePrice();
//                             }
//                             customSnackBar(
//                                 context: context,
//                                 width: 250.w,
//                                 bgColor: UIColor.gold,
//                                 title: response.message.toString());
//                           });
//                         },
//                       ),
//                     );
//                   });
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
