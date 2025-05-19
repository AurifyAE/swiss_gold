import 'dart:developer' as dev;

import '../../../views/delivery/delivery_view.dart';
import '../../models/product_model.dart';
import '../../services/server_provider.dart';
import '../../view_models/product_view_model.dart';
import 'purity_calculation.dart';

double calculateTotalAmount(
      ProductViewModel productViewModel, GoldRateProvider goldRateProvider, DeliveryDetailsView widget) {
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


    dev.log(
        "✅ [TOTAL_AMOUNT_CALC] Final total amount: ${totalAmount > 0 ? totalAmount : 0.0} AED",
        name: "GOLD_CALC");

    return totalAmount > 0 ? totalAmount : 0.0;
  }