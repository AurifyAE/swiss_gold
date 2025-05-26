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

import '../../core/services/local_storage.dart';
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
                 // Updated onTapped method in DeliveryDetailsView (replace the existing onTapped method)

// Updated onTapped method in DeliveryDetailsView (replace the existing onTapped method)

onTapped: () async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(UIColor.gold),
        ),
      );
    },

// Add this import at the top of DeliveryDetailsView file
// import 'package:swiss_gold/core/services/local_storage.dart';

// Updated ProductService.fixPrice method (replace the existing fixPrice method)

  );

  try {
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    final goldRateProvider = Provider.of<GoldRateProvider>(context, listen: false);

    // STEP 1: Prepare fix price payload with current live rates
    List<Map<String, dynamic>> fixPriceBookingData = [];
    List bookingData = widget.orderData["bookingData"] as List;
    
    dev.log('=== STEP 1: PREPARING FIX PRICE DATA ===');
    dev.log('Items to fix price: ${bookingData.length}');

    for (var item in bookingData) {
      String productId = item["productId"];
      int quantity = item["quantity"] ?? 1;

      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
        orElse: () => throw Exception("Product not found: $productId"),
      );

      // Calculate current live price using unified calculation
      Map<String, double> currentPricing = calculateProductPricing(
        product: product,
        quantity: 1, // Fix price per unit first
        goldRateProvider: goldRateProvider,
        calculationContext: "FIX_PRICE for $productId",
      );

      double currentUnitPrice = currentPricing['unitPrice']!;

      // Add each unit separately for fix price
      for (int i = 0; i < quantity; i++) {
        final fixPriceItem = {
          "productId": productId,
          "fixedPrice": currentUnitPrice.round(), // Round to integer as per API example
        };
        fixPriceBookingData.add(fixPriceItem);
        
        dev.log('Added fix price item ${i + 1}/$quantity: ProductId=$productId, FixedPrice=${currentUnitPrice.round()} AED');
      }
    }

    final fixPricePayload = {
      "bookingData": fixPriceBookingData,
    };

    dev.log('=== FIX PRICE PAYLOAD ===');
    dev.log('Total items to fix: ${fixPriceBookingData.length}');
    dev.log('Complete payload: ${jsonEncode(fixPricePayload)}');
    dev.log('========================');

    // STEP 2: Call fix price API
    dev.log('🔒 STEP 2: Calling fix price API...');
    final fixPriceResult = await productViewModel.fixPrice(fixPricePayload);

    if (fixPriceResult == null || fixPriceResult.success != true) {
      Navigator.of(context).pop(); // Close loading dialog
      
      showOrderStatusSnackBar(
        context: context,
        isSuccess: false,
        message: fixPriceResult?.message ?? 'Failed to fix price',
      );
      return;
    }

    dev.log('✅ Price fixed successfully');

    // STEP 3: Prepare booking payload with fixed prices
    dev.log('📦 STEP 3: Preparing booking with fixed prices...');
    List<Map<String, dynamic>> bookingDataWithMakingCharges = [];

    for (var fixedItem in fixPriceBookingData) {
      String productId = fixedItem["productId"];
      
      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
        orElse: () => throw Exception("Product not found: $productId"),
      );

      final bookingItem = {
        "productId": productId,
        "makingCharge": product.makingCharge.toDouble(),
      };
      bookingDataWithMakingCharges.add(bookingItem);
      
      dev.log('Added booking item: ProductId=$productId, MakingCharge=${product.makingCharge}');
    }

    final bookingPayload = {
      "paymentMethod": widget.orderData["paymentMethod"],
      "bookingData": bookingDataWithMakingCharges,
      "deliveryDate": widget.orderData["deliveryDate"],
      "address": widget.orderData["address"],
      "contact": widget.orderData["contact"],
      "priceFixed": true, // Flag to indicate prices are fixed
    };

    dev.log('=== FINAL BOOKING PAYLOAD ===');
    dev.log('PaymentMethod: ${bookingPayload["paymentMethod"]}');
    dev.log('BookingData items: ${bookingDataWithMakingCharges.length}');
    dev.log('PriceFixed: ${bookingPayload["priceFixed"]}');
    dev.log('Complete payload: ${jsonEncode(bookingPayload)}');
    dev.log('==============================');

    // STEP 4: Book products with fixed prices
    dev.log('🛒 STEP 4: Booking products with fixed prices...');
    final bookingResult = await productViewModel.bookProducts(bookingPayload);

    Navigator.of(context).pop(); // Close loading dialog

    if (bookingResult != null && bookingResult.success == true) {
      dev.log('✅ BOOKING SUCCESSFUL');
      
      // Clear cart and quantities
      productViewModel.clearQuantities();
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      await cartViewModel.clearCart();

      // Show success message
      showOrderStatusSnackBar(
        context: context,
        isSuccess: true,
        message: 'Order placed successfully with fixed prices!',
      );

      // Call onConfirm callback
      widget.onConfirm({
        "success": true, 
        "bookingData": bookingResult,
        "fixedPrices": fixPriceBookingData,
      });

      // Navigate back to home with success result
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      dev.log('🏠 Navigated back to home screen successfully');
      
    } else {
      dev.log('❌ BOOKING FAILED: ${bookingResult?.message}');
      
      showOrderStatusSnackBar(
        context: context,
        isSuccess: false,
        message: bookingResult?.message ?? 'Booking failed after price fix',
      );
    }

  } catch (e) {
    dev.log('💥 ERROR during fix price + booking process: ${e.toString()}');
    Navigator.of(context).pop(); // Close loading dialog
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order failed: ${e.toString()}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
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
