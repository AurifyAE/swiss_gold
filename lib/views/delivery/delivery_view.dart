import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/models/product_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/services/server_provider.dart';

import '../../core/utils/money_format_heper.dart';
import '../../core/utils/widgets/snakbar.dart';
import '../../core/view_models/cart_view_model.dart';

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

  double calculatePurityPower(dynamic purity) {
    String purityStr = purity.toString().replaceAll(RegExp(r'\.0$'), '');

    if (purityStr.contains('.')) {
      purityStr = purityStr.replaceAll(RegExp(r'0+$'), '');

      purityStr = purityStr.replaceAll(RegExp(r'\.$'), '');
    }

    int digitCount = purityStr.replaceAll('.', '').length;
    double powerOfTen = pow(10, digitCount).toDouble();
    double result = double.parse(purityStr) / powerOfTen;

    if (purityStr == '9999' || purityStr == '999.9') {
      return 0.9999;
    } else if (purityStr == '999' || purityStr == '99.9') {
      return 0.999;
    } else if (purityStr == '916' || purityStr == '91.6') {
      return 0.916;
    } else if (purityStr == '750' || purityStr == '75.0') {
      return 0.750;
    } else if (purityStr == '585' || purityStr == '58.5') {
      return 0.585;
    } else if (purityStr == '375' || purityStr == '37.5') {
      return 0.375;
    }

    dev.log(
        '🧮 Standardized purity calculation: purity=$purity → cleaned=$purityStr, digits=$digitCount, power=$powerOfTen, result=$result');
    return result;
  }

  double calculateTotalAmount(
      ProductViewModel productViewModel, GoldRateProvider goldRateProvider) {
    double totalAmount = 0.0;
    List bookingData = widget.orderData["bookingData"] as List;

    dev.log("[TOTAL_AMOUNT_CALC] Starting total amount calculation...",
        name: "GOLD_CALC");

    double originalBid = 0.0;
    double biddingPrice = 0.0;
    double askingPrice = 0.0;
    double bidPrice = 0.0;

    if (goldRateProvider.goldData != null) {
      originalBid =
          double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0;
      dev.log("[TOTAL_AMOUNT_CALC] Original bid from socket: $originalBid",
          name: "GOLD_CALC");

      double bidSpread = 0.0;
      double askSpread = 0.0;

      if (goldRateProvider.spotRateData != null) {
        bidSpread = goldRateProvider.spotRateData!.goldBidSpread;
        askSpread = goldRateProvider.spotRateData!.goldAskSpread;
      } else {
        dev.log(
            "[TOTAL_AMOUNT_CALC] Spot rate data is null, using bidSpread=0 and askSpread=0",
            name: "GOLD_CALC");
      }

      biddingPrice = originalBid + bidSpread;
      dev.log(
          "[TOTAL_AMOUNT_CALC] Step 1: Bidding price: $originalBid (bid) + $bidSpread (bid spread) = $biddingPrice",
          name: "GOLD_CALC");

      askingPrice = biddingPrice + askSpread + 0.5;
      dev.log(
          "[TOTAL_AMOUNT_CALC] Step 2: Asking price: $biddingPrice (bidding price) + $askSpread (ask spread) + 0.5 = $askingPrice",
          name: "GOLD_CALC");
    } else {
      dev.log(
          "[TOTAL_AMOUNT_CALC] Warning: Gold data is not available, using zero for bid price",
          name: "GOLD_CALC");
    }

    for (var item in bookingData) {
      String productId = item["productId"];
      int quantity = item["quantity"] ?? 1;

      dev.log(
          "[TOTAL_AMOUNT_CALC] Processing product ID: $productId, quantity: $quantity",
          name: "GOLD_CALC");

      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
      );

      double adjustedAskingPrice = askingPrice;
      if (product.pricingType == 'Premium' && product.value != null ||product.pricingType == 'Discount' && product.value != null ) {
        adjustedAskingPrice += product.value!.toDouble();
        dev.log("==========================================================>>>>>>        ${product.value}");

        dev.log(
            "[TOTAL_AMOUNT_CALC] Applied product premium: $askingPrice + ${product.value} = $adjustedAskingPrice USD/oz",
            name: "GOLD_CALC");
      } 

      bidPrice = adjustedAskingPrice / 31.103 * 3.674;
      dev.log(
          "[TOTAL_AMOUNT_CALC] Converting adjusted asking price to AED/g: $adjustedAskingPrice / 31.103 × 3.674 = $bidPrice AED/g",
          name: "GOLD_CALC");

      double productWeight = double.parse(product.weight.toStringAsFixed(3));
      double purityFactor = calculatePurityPower(product.purity);
      dev.log(
          "[TOTAL_AMOUNT_CALC] Product $productId: weight=${productWeight}g, purity=${product.purity}, purity factor=$purityFactor",
          name: "GOLD_CALC");

      double baseUnitPrice = bidPrice * productWeight * purityFactor;
      dev.log(
          "[TOTAL_AMOUNT_CALC] Base unit price calculation: $bidPrice × $productWeight × $purityFactor  = $baseUnitPrice AED",
          name: "GOLD_CALC");

      double makingCharge = product.makingCharge.toDouble();
      double unitPriceWithMaking = baseUnitPrice + makingCharge;
      dev.log(
          "[TOTAL_AMOUNT_CALC] After adding making charge: $baseUnitPrice + $makingCharge = $unitPriceWithMaking AED",
          name: "GOLD_CALC");

      double itemTotal = unitPriceWithMaking * quantity;
      dev.log(
          "[TOTAL_AMOUNT_CALC] Item total price: $unitPriceWithMaking × $quantity = $itemTotal AED",
          name: "GOLD_CALC");

      totalAmount += itemTotal;
      dev.log(
          "[TOTAL_AMOUNT_CALC] Running total after adding product $productId: $totalAmount AED",
          name: "GOLD_CALC");
    }

    print(
        "✅ [TOTAL_AMOUNT_CALC] Final total amount: ${totalAmount > 0 ? totalAmount : 0.0} AED");

    dev.log(
        "✅ [TOTAL_AMOUNT_CALC] Final total amount: ${totalAmount > 0 ? totalAmount : 0.0} AED",
        name: "GOLD_CALC");

    return totalAmount > 0 ? totalAmount : 0.0;
  }

  double calculateBidPriceForDisplay(
      GoldRateProvider goldRateProvider, ProductViewModel productViewModel) {
    double originalBid = 0.0;
    double biddingPrice = 0.0;
    double askingPrice = 0.0;
    double bidPrice = 0.0;

    if (goldRateProvider.goldData != null) {
      originalBid =
          double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0;
      dev.log("🟡 Original bid from socket for display: $originalBid");

      if (goldRateProvider.spotRateData != null) {
        double bidSpread = goldRateProvider.spotRateData!.goldBidSpread;
        double askSpread = goldRateProvider.spotRateData!.goldAskSpread;

        biddingPrice = originalBid + bidSpread;
        dev.log(
            "🧮 Display bid calculation step 1: Bidding price = $originalBid (bid) + $bidSpread (bid spread) = $biddingPrice");

        askingPrice = biddingPrice + askSpread + 0.5;
        dev.log(
            "🧮 Display bid calculation step 2: Asking price = $biddingPrice (bidding price) + $askSpread (ask spread) + 0.5 = $askingPrice");

        bidPrice = askingPrice / 31.103 * 3.674;
        dev.log(
            "🧮 Display bid calculation step 3: Final price = $askingPrice / 31.103 × 3.674 = $bidPrice AED/g");
      } else {
        bidPrice = originalBid / 31.103 * 3.674;
        dev.log(
            "⚠️ Display bid using original bid (no spot rates): $originalBid / 31.103 × 3.674 = $bidPrice AED/g");
      }
    } else {
      dev.log("⚠️ Warning: Gold data is not available for display, using zero");
    }

    return bidPrice;
  }

  double getProductUnitPrice(String productId,
      ProductViewModel productViewModel, GoldRateProvider goldRateProvider) {
    Product product = productViewModel.productList.firstWhere(
      (p) => p.pId == productId,
    );

    double originalBid = 0.0;
    double askingPrice = 0.0;

    if (goldRateProvider.goldData != null) {
      originalBid =
          double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0;

      if (goldRateProvider.spotRateData != null) {
        double bidSpread = goldRateProvider.spotRateData!.goldBidSpread;
        double askSpread = goldRateProvider.spotRateData!.goldAskSpread;

        double biddingPrice = originalBid + bidSpread;
        askingPrice = biddingPrice + askSpread + 0.5;
      } else {
        askingPrice = originalBid;
      }
    }

    double adjustedAskingPrice = askingPrice;
    if (product.pricingType == 'Premium' && product.value != null) {
      adjustedAskingPrice += product.value!.toDouble();
    } else if (product.pricingType == 'Discount' && product.value != null) {
      adjustedAskingPrice -= product.value!.toDouble();
    }

    double bidPrice = adjustedAskingPrice / 31.103 * 3.674;

    double productWeight = double.parse(product.weight.toStringAsFixed(3));
    double purityFactor = calculatePurityPower(product.purity);

    double basePrice = bidPrice * purityFactor * productWeight;
    dev.log(
        "Product $productId base price: $bidPrice × $purityFactor × $productWeight = $basePrice AED");

    double priceWithMakingCharge = basePrice + product.makingCharge.toDouble();

    return priceWithMakingCharge;
  }

  Product? getProductById(String productId, ProductViewModel productViewModel) {
    try {
      Product product =
          productViewModel.productList.firstWhere((p) => p.pId == productId);
      dev.log(
          "Retrieved product ID: $productId - Title: ${product.title}, Weight: ${product.weight}g, Purity: ${product.purity}");
      return product;
    } catch (e) {
      dev.log(
          "Failed to retrieve product ID: $productId - Error: ${e.toString()}");
      return null;
    }
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

    final totalAmount =
        calculateTotalAmount(productViewModel, goldRateProvider);

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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: UIColor.gold),
                    color: UIColor.gold.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Gold Payment',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Total Gold: ${formatNumber(totalWeight)} g',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: UIColor.gold),
                    color: UIColor.gold.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Cash Payment',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Live rate: ${bidPrice > 0 ? formatNumber(bidPrice) : "2,592.97"}',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Total Amount: AED ${formatNumber(totalAmount)}',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: UIColor.gold),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method:',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          widget.orderData["paymentMethod"] ?? 'Not specified',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Date:',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          widget.orderData["deliveryDate"] ?? 'Not specified',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          '${(widget.orderData["bookingData"] as List).length}',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!isGoldPayment) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            'AED ${formatNumber(totalAmount)}',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: (widget.orderData["bookingData"] as List).length,
                itemBuilder: (context, index) {
                  final item = (widget.orderData["bookingData"] as List)[index];
                  final productId = item["productId"];
                  final quantity = item["quantity"] ?? 1;

                  final product = getProductById(productId, productViewModel);
                  final productWeight = product?.weight.toDouble() ?? 0.0;
                  final productPurity = product?.purity.toDouble() ?? 0.0;
                  final makingCharge = product?.makingCharge.toDouble() ?? 0.0;
                  final productTitle = product?.title ?? 'Product #$productId';

                  dev.log(
                      "📦 Product #$index - ID: $productId, Title: $productTitle");
                  dev.log(
                      "📊 Product #$index - Weight: $productWeight g, Purity: $productPurity, Making Charge: $makingCharge AED");

                  double originalBid = 0.0;
                  double biddingPrice = 0.0;
                  double askingPrice = 0.0;

                  if (goldRateProvider.goldData != null) {
                    originalBid = double.tryParse(
                            '${goldRateProvider.goldData!['bid']}') ??
                        0.0;

                    if (goldRateProvider.spotRateData != null) {
                      double bidSpread =
                          goldRateProvider.spotRateData!.goldBidSpread;
                      double askSpread =
                          goldRateProvider.spotRateData!.goldAskSpread;

                      biddingPrice = originalBid + bidSpread;
                      askingPrice = biddingPrice + askSpread + 0.5;
                      dev.log(
                          "🧮 Product #$index - Asking price: $askingPrice USD/oz");
                    } else {
                      askingPrice = originalBid;
                      dev.log(
                          "⚠️ Product #$index - Using original bid as asking price: $askingPrice USD/oz");
                    }
                  }

                  double adjustedAskingPrice = askingPrice;
                  if (product != null) {
                    if (product.pricingType == 'Premium' &&
                        product.value != null) {
                      adjustedAskingPrice += product.value!.toDouble();
                      dev.log(
                          "💰 Product #$index - Premium applied to asking price: $askingPrice + ${product.value} = $adjustedAskingPrice USD/oz");
                    } else if (product.pricingType == 'Discount' &&
                        product.value != null) {
                      adjustedAskingPrice -= product.value!.toDouble();
                      dev.log(
                          "💸 Product #$index - Discount applied to asking price: $askingPrice - ${product.value} = $adjustedAskingPrice USD/oz");
                    }
                  }

                  final productBidPrice = adjustedAskingPrice / 31.103 * 3.674;
                  dev.log(
                      "🧮 Product #$index - Converted rate: $adjustedAskingPrice / 31.103 × 3.674 = $productBidPrice AED/g");

                  final purityFactor = calculatePurityPower(productPurity);
                  dev.log(
                      "🧮 Product #$index - Purity factor: $purityFactor (calculated from $productPurity)");

                  final basePrice =
                      productBidPrice * productWeight * purityFactor;
                  dev.log(
                      "🧮 Product #$index - Base price calculation: $productBidPrice × $purityFactor × $productWeight  = $basePrice AED");

                  final unitPrice = basePrice + makingCharge;
                  dev.log(
                      "🧮 Product #$index - Unit price calculation: $basePrice + $makingCharge = $unitPrice AED");

                  final itemValue = unitPrice * quantity;
                  dev.log(
                      "🧾 Product #$index - Item total calculation: $unitPrice × $quantity = $itemValue AED");

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: UIColor.gold.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productTitle,
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weight per Unit:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              '${formatNumber(productWeight)} g',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Purity:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              productPurity.toInt().toString(),
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Weight:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              '${formatNumber(productWeight * quantity)} g',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        if (!isGoldPayment) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Base Price:',
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                ),
                              ),
                              Text(
                                'AED ${formatNumber(basePrice)}',
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Item Total:',
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'AED ${formatNumber(itemValue)}',
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(height: 12.h),
                    if (isGoldPayment) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Gold Payment:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${formatNumber(totalWeight)} g',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isGoldPayment) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Cash Payment:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'AED ${formatNumber(totalAmount)}',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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
                      double biddingPrice = 0.0;
                      double askingPrice = 0.0;
                      double bidPrice = 0.0;

                      if (goldRateProvider.goldData != null) {
                        originalBid = double.tryParse(
                                '${goldRateProvider.goldData!['bid']}') ??
                            0.0;
                        dev.log(
                            "🟡 Order submission - Original bid: $originalBid");

                        if (goldRateProvider.spotRateData != null) {
                          double bidSpread =
                              goldRateProvider.spotRateData!.goldBidSpread;
                          double askSpread =
                              goldRateProvider.spotRateData!.goldAskSpread;

                          biddingPrice = originalBid + bidSpread;
                          askingPrice = biddingPrice + askSpread + 0.5;
                          bidPrice = askingPrice / 31.103 * 3.674;
                        } else {
                          bidPrice = originalBid / 31.103 * 3.674;
                          askingPrice = originalBid;
                        }
                      }

                      List<Map<String, dynamic>> bookingDataWithMakingCharges =
                          [];
                      List bookingData =
                          widget.orderData["bookingData"] as List;

                      for (var item in bookingData) {
                        String productId = item["productId"];
                        int quantity = item["quantity"] ?? 1;

                        Product product =
                            productViewModel.productList.firstWhere(
                          (p) => p.pId == productId,
                          orElse: () =>
                              throw Exception("Product not found: $productId"),
                        );

                        for (int i = 0; i < quantity; i++) {
                          bookingDataWithMakingCharges.add({
                            "productId": productId,
                            "makingCharge": product.makingCharge.toDouble()
                          });
                        }
                      }

                      final bookingPayload = {
                        "paymentMethod": widget.orderData["paymentMethod"],
                        "bookingData": bookingDataWithMakingCharges,
                        "deliveryDate": widget.orderData["deliveryDate"],
                        "address": widget.orderData["address"],
                        "contact": widget.orderData["contact"]
                      };

                      dev.log("Booking payload: ${jsonEncode(bookingPayload)}");

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
