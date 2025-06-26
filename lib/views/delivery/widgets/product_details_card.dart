import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/server_provider.dart';
import '../../../core/utils/calculations/get_product.dart';
import '../../../core/utils/calculations/total_amount_calculation.dart';
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: (widget.orderData["bookingData"] as List).length,
      itemBuilder: (context, index) {
        final item = (widget.orderData["bookingData"] as List)[index];
        final productId = item["productId"];
        final quantity = item["quantity"] ?? 1;

        final product = getProductById(productId, productViewModel);
        if (product == null) {
          dev.log("❌ Product not found: $productId", name: "PRODUCT_DETAILS");
          return const SizedBox.shrink();
        }

        final productWeight = product.weight.toDouble();  
        final productPurity = product.purity.toDouble();
        final makingCharge = product.makingCharge.toDouble();
        final productTitle = product.title;

        dev.log("📦 Product #$index - ID: $productId, Title: $productTitle", name: "PRODUCT_DETAILS");

        // Use the unified calculation function
        Map<String, double> pricing = calculateProductPricing(
          product: product,
          quantity: quantity,
          goldRateProvider: goldRateProvider,
          calculationContext: "PRODUCT_DETAILS Item #$index ($productTitle)",
        );

        final basePrice = pricing['basePrice']!;
        final itemValue = pricing['itemTotal']!;

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
                    '${productWeight} g', 
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
                    '${productWeight * quantity} g',
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
              ],
            ],
          ),
        );
      },
    );
  }
}