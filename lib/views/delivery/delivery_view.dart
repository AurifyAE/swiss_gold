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
                 // Updated onTapped method in DeliveryDetailsView (replace the existing onTapped method)

// Updated onTapped method in DeliveryDetailsView (replace the existing onTapped method)

onTapped: () async {
  // Show loading dialog
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
  );

  try {
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    final goldRateProvider = Provider.of<GoldRateProvider>(context, listen: false);

    dev.log('🚀 === STARTING ORDER PROCESS ===');
    dev.log('Payment Method: ${widget.orderData["paymentMethod"]}');
    dev.log('Original Booking Data: ${jsonEncode(widget.orderData["bookingData"])}');
    dev.log('Gold Rate Connected: ${goldRateProvider.isConnected}');
    dev.log('Current Gold Data: ${goldRateProvider.goldData}');
    dev.log('=====================================');

    // STEP 1: Prepare fix price payload with current live rates
    List<Map<String, dynamic>> fixPriceBookingData = [];
    List bookingData = widget.orderData["bookingData"] as List;
    
    dev.log('🔧 === STEP 1: PREPARING FIX PRICE DATA ===');
    dev.log('Items to process for fix price: ${bookingData.length}');

    for (var item in bookingData) {
      String productId = item["productId"];
      int quantity = item["quantity"] ?? 1;

      dev.log('Processing item: ProductId=$productId, Quantity=$quantity');

      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
        orElse: () => throw Exception("Product not found: $productId"),
      );

      dev.log('Found Product: ${product.title}, Weight: ${product.weight}g, MakingCharge: ${product.makingCharge}');

      // Calculate current live price using unified calculation
      Map<String, double> currentPricing = calculateProductPricing(
        product: product,
        quantity: 1, // Fix price per unit first
        goldRateProvider: goldRateProvider,
        calculationContext: "FIX_PRICE for $productId",
      );

      double currentUnitPrice = currentPricing['unitPrice']!;
      dev.log('Calculated Unit Price: $currentUnitPrice AED');

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

    dev.log('🔒 === FIX PRICE PAYLOAD SUMMARY ===');
    dev.log('Total items to fix: ${fixPriceBookingData.length}');
    dev.log('Complete payload: ${jsonEncode(fixPricePayload)}');
    dev.log('===================================');

    // STEP 2: Call fix price API
    dev.log('🔒 === STEP 2: CALLING FIX PRICE API ===');
    final fixPriceResult = await productViewModel.fixPrice(fixPricePayload);

    dev.log('Fix Price API Response: ${fixPriceResult.toString()}');

    // Updated fix price success check - check for message instead of success field
    if (fixPriceResult == null || 
        fixPriceResult.message == null || 
        !fixPriceResult.message!.toLowerCase().contains('fixed successfully')) {
      dev.log('❌ FIX PRICE FAILED');
      dev.log('Error Message: ${fixPriceResult?.message}');
      
      Navigator.of(context).pop(); // Close loading dialog
      
      showOrderStatusSnackBar(
        context: context,
        isSuccess: false,
        message: fixPriceResult?.message ?? 'Failed to fix price',
      );
      return;
    }

    dev.log('✅ PRICE FIXED SUCCESSFULLY');
    dev.log('Fix Price Result: ${fixPriceResult.message}');

    // STEP 3: Prepare booking payload with fixed prices
    dev.log('📦 === STEP 3: PREPARING BOOKING PAYLOAD ===');
    List<Map<String, dynamic>> bookingDataWithMakingCharges = [];

    // Group by productId and get makingCharge from original booking data
    for (var item in bookingData) {
      String productId = item["productId"];
      int quantity = item["quantity"] ?? 1;
      
      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
        orElse: () => throw Exception("Product not found: $productId"),
      );

      dev.log('Processing booking for: ProductId=$productId, Quantity=$quantity, MakingCharge=${product.makingCharge}');

      // Add each unit separately (as per fix price structure)
      for (int i = 0; i < quantity; i++) {
        final bookingItem = {
          "productId": productId,
          "makingCharge": product.makingCharge.toDouble(),
        };
        bookingDataWithMakingCharges.add(bookingItem);
        dev.log('Added booking item ${i + 1}/$quantity: ProductId=$productId, MakingCharge=${product.makingCharge}');
      }
    }

    // Simplified booking payload (only required fields)
    final bookingPayload = {
      "paymentMethod": widget.orderData["paymentMethod"],
      "bookingData": bookingDataWithMakingCharges,
    };

    dev.log('📦 === FINAL BOOKING PAYLOAD ===');
    dev.log('PaymentMethod: ${bookingPayload["paymentMethod"]}');
    dev.log('BookingData items: ${bookingDataWithMakingCharges.length}');
    dev.log('Complete booking payload: ${jsonEncode(bookingPayload)}');
    dev.log('================================');

    // STEP 4: Book products with fixed prices
    dev.log('🛒 === STEP 4: CALLING BOOKING API ===');
    final bookingResult = await productViewModel.bookProducts(bookingPayload);

    dev.log('Booking API Response: ${bookingResult.toString()}');

    // Close loading dialog
    Navigator.of(context).pop();

    // Updated booking success check to handle both success field and message
    if (bookingResult != null && 
    (bookingResult.success == true || 
     (bookingResult.message != null && 
      bookingResult.message!.toLowerCase().contains('success')))) {
  
  dev.log('🎉 === BOOKING SUCCESSFUL ===');
  dev.log('Booking Message: ${bookingResult.message}');
  dev.log('Booking Success: ${bookingResult.success}');
  
  // Show success message first
  showOrderStatusSnackBar(
    context: context,
    isSuccess: true,
    message: 'Order placed successfully',
  );

  // Clear cart and quantities ONLY after successful booking
  dev.log('🧹 Clearing cart and quantities after successful booking...');
  productViewModel.clearQuantities();
  final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
  await cartViewModel.clearCart();
  dev.log('✅ Cart cleared successfully');

  // Call onConfirm callback with success flag
  dev.log('📞 Calling onConfirm callback...');
  widget.onConfirm({
    "success": true, 
    "bookingResult": bookingResult,
    "fixedPrices": fixPriceBookingData,
    "message": bookingResult.message,
  });

  // Navigate back with success result - THIS IS THE KEY CHANGE
  dev.log('🏠 Navigating back to home screen with success result...');
  Navigator.of(context).pop({
    "orderSuccess": true,
    "message": "Order placed successfully"
  });
  
  dev.log('✅ === ORDER PROCESS COMPLETED SUCCESSFULLY ===');
  
} else {
      dev.log('❌ === BOOKING FAILED ===');
      dev.log('Booking Error Message: ${bookingResult?.message}');
      dev.log('Booking Success Status: ${bookingResult?.success}');
      dev.log('Full Booking Response: ${bookingResult.toString()}');
      
      showOrderStatusSnackBar(
        context: context,
        isSuccess: false,
        message: bookingResult?.message ?? 'Booking failed after price fix',
      );
    }

  } catch (e, stackTrace) {
    dev.log('💥 === CRITICAL ERROR IN ORDER PROCESS ===');
    dev.log('Error: ${e.toString()}');
    dev.log('Stack Trace: ${stackTrace.toString()}');
    dev.log('==========================================');
    
    // Close loading dialog if still open
    Navigator.of(context).pop();
    
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
