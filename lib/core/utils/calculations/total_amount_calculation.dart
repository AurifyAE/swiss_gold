import 'dart:developer' as dev;
import '../../models/product_model.dart';
import '../../services/server_provider.dart';
import '../../view_models/product_view_model.dart';
import 'purity_calculation.dart';

// Create a unified calculation function that both components will use
Map<String, double> calculateProductPricing({
  required Product product,
  required int quantity,
  required GoldRateProvider goldRateProvider,
  required String calculationContext,
}) {
  dev.log("[UNIFIED_CALC] ========== Starting $calculationContext ==========", name: "PRICE_CALC");
  
  double originalBid = 0.0;
  double biddingPrice = 0.0;
  double askingPrice = 0.0;

  // Step 1: Get base gold rates
  if (goldRateProvider.goldData != null) {
    originalBid = double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0;
    dev.log("[UNIFIED_CALC] Original bid from socket: $originalBid", name: "PRICE_CALC");

    double bidSpread = 0.0;
    double askSpread = 0.0;

    if (goldRateProvider.spotRateData != null) {
      bidSpread = goldRateProvider.spotRateData!.goldBidSpread;
      askSpread = goldRateProvider.spotRateData!.goldAskSpread;
    }

    biddingPrice = originalBid + bidSpread;
    askingPrice = biddingPrice + askSpread + 0.5;
    
    dev.log("[UNIFIED_CALC] Base calculation: bid=$originalBid, bidSpread=$bidSpread, askSpread=$askSpread", name: "PRICE_CALC");
    dev.log("[UNIFIED_CALC] Final asking price: $askingPrice USD/oz", name: "PRICE_CALC");
  }

  // Step 2: Apply product-specific premium/discount
  double adjustedAskingPrice = askingPrice;
  if (product.pricingType == 'Premium' && product.value != null) {
    adjustedAskingPrice += product.value!.toDouble();
    dev.log("[UNIFIED_CALC] Premium applied: $askingPrice + ${product.value} = $adjustedAskingPrice USD/oz", name: "PRICE_CALC");
  } else if (product.pricingType == 'Discount' && product.value != null) {
    adjustedAskingPrice -= product.value!.toDouble();
    dev.log("[UNIFIED_CALC] Discount applied: $askingPrice + ${product.value} = $adjustedAskingPrice USD/oz", name: "PRICE_CALC");
  }

  // Step 3: Convert to AED/g
  double bidPriceAEDPerGram = adjustedAskingPrice / 31.103 * 3.674;
  dev.log("[UNIFIED_CALC] Converting to AED/g: $adjustedAskingPrice / 31.103 × 3.674 = $bidPriceAEDPerGram", name: "PRICE_CALC");

  // Step 4: Calculate product specifics
  double productWeight = double.parse(product.weight.toStringAsFixed(3));
  double purityFactor = calculatePurityPower(product.purity);
  double makingCharge = product.makingCharge.toDouble();
  
  dev.log("[UNIFIED_CALC] Product details: weight=$productWeight g, purity=${product.purity}, purityFactor=$purityFactor, makingCharge=$makingCharge", name: "PRICE_CALC");

  // Step 5: Calculate final prices
  double basePrice = bidPriceAEDPerGram * productWeight * purityFactor;
  double unitPrice = basePrice + makingCharge;
  double itemTotal = unitPrice * quantity;

  dev.log("[UNIFIED_CALC] Final calculations:", name: "PRICE_CALC");
  dev.log("[UNIFIED_CALC] Base price: $bidPriceAEDPerGram × $productWeight × $purityFactor = $basePrice AED", name: "PRICE_CALC");
  dev.log("[UNIFIED_CALC] Unit price: $basePrice + $makingCharge = $unitPrice AED", name: "PRICE_CALC");
  dev.log("[UNIFIED_CALC] Item total: $unitPrice × $quantity = $itemTotal AED", name: "PRICE_CALC");
  dev.log("[UNIFIED_CALC] ========== End $calculationContext ==========", name: "PRICE_CALC");

  return {
    'bidPriceAEDPerGram': bidPriceAEDPerGram,
    'basePrice': basePrice,
    'unitPrice': unitPrice,
    'itemTotal': itemTotal,
  };
}

// Updated calculateTotalAmount function
double calculateTotalAmount(
    ProductViewModel productViewModel, 
    GoldRateProvider goldRateProvider, 
    dynamic widget) {
  
  double totalAmount = 0.0;
  List bookingData = widget.orderData["bookingData"] as List;

  dev.log("[TOTAL_CALC] Starting total amount calculation for ${bookingData.length} items", name: "TOTAL_CALC");

  for (int index = 0; index < bookingData.length; index++) {
    var item = bookingData[index];
    String productId = item["productId"];
    int quantity = item["quantity"] ?? 1;

    Product product = productViewModel.productList.firstWhere((p) => p.pId == productId);
    
    Map<String, double> pricing = calculateProductPricing(
      product: product,
      quantity: quantity,
      goldRateProvider: goldRateProvider,
      calculationContext: "TOTAL_CALC Item #$index (${product.title})",
    );

    totalAmount += pricing['itemTotal']!;
    dev.log("[TOTAL_CALC] Running total after item #$index: $totalAmount AED", name: "TOTAL_CALC");
  }

  dev.log("[TOTAL_CALC] ✅ Final total amount: $totalAmount AED", name: "TOTAL_CALC");
  return totalAmount > 0 ? totalAmount : 0.0;
}