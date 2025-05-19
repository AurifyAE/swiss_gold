// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/models/product_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/services/server_provider.dart';

import '../../core/utils/calculations/bid_price_calculation.dart';
import '../../core/utils/calculations/total_amount_calculation.dart';
import '../../core/utils/widgets/snakbar.dart';
import '../../core/view_models/cart_view_model.dart';
import 'widgets/cash_summary_card.dart';
import 'widgets/gold_summary_card.dart';
import 'widgets/order_summary_card.dart';
import 'widgets/payment_card.dart';
import 'widgets/product_details_card.dart';

class DeliveryDetailsView extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final Function(Map<String, dynamic>) onConfirm;

  const DeliveryDetailsView({
    super.key,
    required this.orderData,
    required this.onConfirm,
  });

  @override
  State<DeliveryDetailsView> createState() => _DeliveryDetailsViewState();
}

class _DeliveryDetailsViewState extends State<DeliveryDetailsView> {
  double calculateTotalWeight(ProductViewModel productViewModel) {
    double totalWeight = 0.0;
    List bookingData = widget.orderData["bookingData"] as List;

    dev.log("Starting total weight calculation with 3 digit precision...");

    for (var item in bookingData) {
      String productId = item["productId"];
      int quantity = item["quantity"] ?? 1;

      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
      );

      double productWeight = double.parse(product.weight.toStringAsFixed(3));
      totalWeight += productWeight * quantity;

      dev.log(
          "Product $productId: weight=${productWeight}g × quantity=$quantity = ${(productWeight * quantity).toStringAsFixed(3)}g");
    }

    dev.log(
        "Final total weight calculation: ${totalWeight.toStringAsFixed(3)}g");
    return totalWeight;
  }

  @override
  void initState() {
    super.initState();
    dev.log("Initializing DeliveryDetailsView");

    Future.microtask(() {
      final goldRateProvider =
          Provider.of<GoldRateProvider>(context, listen: false);
      if (!goldRateProvider.isConnected || goldRateProvider.goldData == null) {
        dev.log(
            "Initializing gold rate connection - Current status: isConnected=${goldRateProvider.isConnected}, hasData=${goldRateProvider.goldData != null}");
        goldRateProvider.initializeConnection();
      } else {
        dev.log(
            "Gold rate already connected - Current bid: ${goldRateProvider.goldData!['bid']}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final goldRateProvider = Provider.of<GoldRateProvider>(context);

    final isGoldPayment = widget.orderData["paymentMethod"] == 'Gold';
    final totalWeight = calculateTotalWeight(productViewModel);

    final totalAmount = calculateTotalAmount(
      productViewModel,
      goldRateProvider, widget
    );

    double bidPrice =
        calculateBidPriceForDisplay(goldRateProvider, productViewModel);

    dev.log("📊 Summary - Payment method: ${isGoldPayment ? 'Gold' : 'Cash'}");
    dev.log("📊 Summary - Total weight: $totalWeight g");
    dev.log("📊 Summary - Total amount: $totalAmount AED");
    dev.log("📊 Summary - Current bid price: $bidPrice AED/g");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Order Confirmation',
          style: TextStyle(
            color: UIColor.gold,
            fontFamily: 'Familiar',
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: UIColor.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              if (isGoldPayment)
                GoldSummaryCard(totalWeight: totalWeight)
              else
                CashSummaryCard(bidPrice: bidPrice, totalAmount: totalAmount),
              SizedBox(height: 20.h),
              PaymentCard(
                  widget: widget,
                  isGoldPayment: isGoldPayment,
                  totalAmount: totalAmount),
              SizedBox(height: 24.h),
              Text(
                'Product Details',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              ProductDetailsCard(
                  widget: widget,
                  productViewModel: productViewModel,
                  goldRateProvider: goldRateProvider,
                  isGoldPayment: isGoldPayment),
              SizedBox(height: 30.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: isGoldPayment
                      ? UIColor.gold.withOpacity(0.15)
                      : UIColor.gold.withOpacity(0.1),
                  border: Border.all(color: UIColor.gold),
                ),
                child: OrderSummaryCard(
                    isGoldPayment: isGoldPayment,
                    totalWeight: totalWeight,
                    totalAmount: totalAmount),
              ),
              SizedBox(height: 30.h),
              Center(
                child: CustomOutlinedBtn(
                  borderRadius: 12.sp,
                  borderColor: UIColor.gold,
                  padH: 12.w,
                  padV: 12.h,
                  width: 200.w,
                  onTapped: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(UIColor.gold),
                          ),
                        );
                      },
                    );

                    try {
                      final productViewModel =
                          Provider.of<ProductViewModel>(context, listen: false);
                      final goldRateProvider =
                          Provider.of<GoldRateProvider>(context, listen: false);

                      double originalBid = 0.0;

                      if (goldRateProvider.goldData != null) {
                        originalBid = double.tryParse(
                                '${goldRateProvider.goldData!['bid']}') ??
                            0.0;
                        dev.log(
                            "🟡 Order submission - Original bid: $originalBid");

                        if (goldRateProvider.spotRateData != null) {

                        } else {
                        }
                      }

                      // In the UI button onTapped method - replace the booking preparation section:

                      List<Map<String, dynamic>> bookingDataWithMakingCharges =
                          [];
                      List bookingData =
                          widget.orderData["bookingData"] as List;
                      dev.log('=== PREPARING BOOKING DATA ===');
                      dev.log(
                          'Original orderData: ${jsonEncode(widget.orderData)}');
                      dev.log('Items to process: ${bookingData.length}');

                      for (var item in bookingData) {
                        String productId = item["productId"];
                        int quantity = item["quantity"] ?? 1;

                        dev.log(
                            'Processing item - ProductId: $productId, Quantity: $quantity');

                        Product product =
                            productViewModel.productList.firstWhere(
                          (p) => p.pId == productId,
                          orElse: () =>
                              throw Exception("Product not found: $productId"),
                        );

                        dev.log(
                            'Found product - Making Charge: ${product.makingCharge}');

                        for (int i = 0; i < quantity; i++) {
                          final bookingItem = {
                            "productId": productId,
                            "makingCharge": product.makingCharge.toDouble()
                          };
                          bookingDataWithMakingCharges.add(bookingItem);
                          dev.log(
                              'Added booking item ${i + 1}/$quantity: ${jsonEncode(bookingItem)}');
                        }
                      }

                      final bookingPayload = {
                        "paymentMethod": widget.orderData["paymentMethod"],
                        "bookingData": bookingDataWithMakingCharges,
                        "deliveryDate": widget.orderData["deliveryDate"],
                        "address": widget.orderData["address"],
                        "contact": widget.orderData["contact"]
                      };

                      dev.log('=== FINAL BOOKING PAYLOAD ===');
                      dev.log(
                          'PaymentMethod: ${bookingPayload["paymentMethod"]}');
                      dev.log(
                          'BookingData items: ${bookingDataWithMakingCharges.length}');
                      dev.log(
                          'Complete payload: ${jsonEncode(bookingPayload)}');
                      dev.log('==============================');

                      dev.log(
                          "Booking payload being sent: ${jsonEncode(bookingPayload)}");

                      final bookingResult =
                          await productViewModel.bookProducts(bookingPayload);

                      Navigator.of(context).pop();

                      if (bookingResult != null && bookingResult.success!) {
                        productViewModel.clearQuantities();

                        final cartViewModel =
                            Provider.of<CartViewModel>(context, listen: false);
                        await cartViewModel.clearCart();
                        productViewModel.clearQuantities();

                        widget.onConfirm(
                            {"success": true, "bookingData": bookingResult});

                        showOrderStatusSnackBar(
                          context: context,
                          isSuccess: true,
                          message: 'Booking success',
                        );

                        Navigator.pop(context, {"orderSuccess": true});
                      } else {
                        showOrderStatusSnackBar(
                          context: context,
                          isSuccess: false,
                          message: bookingResult?.message ?? 'Booking failed',
                        );

                        Navigator.pop(context, {"orderSuccess": false});
                      }
                    } catch (e) {
                      dev.log(
                          "Error during order confirmation: ${e.toString()}");
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'An error occurred: ${e.toString()}',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );

                      Navigator.pop(context,
                          {"orderSuccess": false, "error": e.toString()});
                    }
                  },
                  btnTextColor: UIColor.gold,
                  btnText: 'Confirm Order',
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context, {"orderSuccess": false, "cancelled": true});
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: UIColor.gold.withOpacity(0.8),
                      fontFamily: 'Familiar',
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
