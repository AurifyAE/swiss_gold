
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/server_provider.dart';
import '../../../core/utils/calculations/get_product.dart';
import '../../../core/utils/calculations/purity_calculation.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/money_format_heper.dart';
import '../../../core/view_models/product_view_model.dart';
import '../delivery_view.dart';

class ProductDetailsCard extends StatelessWidget {
  const ProductDetailsCard({
    super.key,
    required this.widget,
    required this.productViewModel,
    required this.goldRateProvider,
    required this.isGoldPayment,
  });

  final DeliveryDetailsView widget;
  final ProductViewModel productViewModel;
  final GoldRateProvider goldRateProvider;
  final bool isGoldPayment;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
            // ignore: deprecated_member_use
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
    );
  }
}