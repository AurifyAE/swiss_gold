import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';

import '../../core/models/pending_order_model.dart';
import '../../core/models/product_model.dart';
import '../../core/services/local_storage.dart';
import '../../core/services/server_provider.dart';
import '../../core/utils/calculations/bid_price_calculation.dart';
import '../../core/utils/calculations/get_product.dart';
import '../../core/utils/calculations/total_amount_calculation.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/money_format_heper.dart';
import '../../core/view_models/pending_provider.dart';
import '../../core/view_models/product_view_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final PendingOrder order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}



class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {


bool isGoldPayment = widget.order.paymentMethod.toLowerCase() == 'gold';
   

    
        
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: UIColor.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: TextStyle(
            color: UIColor.gold,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildOrderSummaryCard(),
            const SizedBox(height: 16),
            
            // Payment Details Card
            _buildPaymentDetailsCard(),
            const SizedBox(height: 16),
            
            // Product Details Card
            _buildProductDetailsCard(),
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  double calculateOrderTotal(ProductViewModel productViewModel, GoldRateProvider goldRateProvider) {
  double totalAmount = 0.0;
  
  for (var item in widget.order.items) {
    // Get the actual product
    Product? product = getProductById(item.productId.id, productViewModel);
    if (product != null) {
      // Calculate pricing for this item
      Map<String, double> pricing = calculateProductPricing(
        product: product,
        quantity: item.quantity,
        goldRateProvider: goldRateProvider,
        calculationContext: "OrderTotal - ${product.title}",
      );
      totalAmount += pricing['itemTotal']!;
    }
  }
  
  return totalAmount;
}

 Widget _buildOrderSummaryCard() {
  final productViewModel = Provider.of<ProductViewModel>(context);
  final goldRateProvider = Provider.of<GoldRateProvider>(context);

  bool isGoldPayment = widget.order.paymentMethod.toLowerCase() == 'gold';
  
  // Use the proper calculation instead of dummy data
  double bidPrice = calculateBidPriceForDisplay(goldRateProvider, productViewModel);
  
  // Calculate total using our helper method
  final totalAmount = calculateOrderTotal(productViewModel, goldRateProvider);
  
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: UIColor.gold,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(  
          'User Approval Pending',
          style: TextStyle(
            color: UIColor.gold,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Live rate: ${bidPrice > 0 ? formatNumber(bidPrice) : "Loading..."}', // Remove dummy data
          style: TextStyle(
            color: UIColor.gold.withOpacity(0.8), 
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),

        if (isGoldPayment)
         SizedBox.shrink() 
        else
           Text( 
            'Total Amount: AED ${formatNumber(totalAmount)}',  
            style: TextStyle(
              color: UIColor.gold,
              fontSize: 18,
              fontWeight: FontWeight.w600,  
            ),
          ),
        
      ],
    ),
  );
}

Widget _buildPaymentDetailsCard() {
  final productViewModel = Provider.of<ProductViewModel>(context);
  final goldRateProvider = Provider.of<GoldRateProvider>(context);
  
  // Calculate the actual total amount using our helper method
  final actualTotalAmount = calculateOrderTotal(productViewModel, goldRateProvider);

    bool isGoldPayment = widget.order.paymentMethod.toLowerCase() == 'gold'; 
  
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: UIColor.gold,
        width: 1,
      ),
    ),
    child: Column(
      children: [
        _buildDetailRow('Payment Method:', widget.order.paymentMethod),
        _buildDetailRow('Delivery Date:', DateFormatter.formatDeliveryDate(widget.order.orderDate)),
        _buildDetailRow('Total Items:', '${widget.order.items.length}'),
       if (!isGoldPayment) ...[
          _buildDetailRow('Live Calculated Total:', CurrencyFormatter.formatAED(actualTotalAmount)),
          _buildDetailRow('Original Order Total:', CurrencyFormatter.formatAED(widget.order.totalPrice)),
        ], 
        
      
      ],
    ),
  );
}

  Widget _buildProductDetailsCard() {
    return Container( 
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: UIColor.gold,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: TextStyle(
              color: UIColor.gold,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.order.items.map((item) => _buildProductItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {
  final productViewModel = Provider.of<ProductViewModel>(context);
  final goldRateProvider = Provider.of<GoldRateProvider>(context);
  
  // Get the actual product details
  Product? product = getProductById(item.productId.id, productViewModel);

   bool isGoldPayment = widget.order.paymentMethod.toLowerCase() == 'gold'; 
  
  if (product == null) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: UIColor.gold, width: 1),
      ),
      child: Text(
        'Product not found',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
  
  // Calculate proper pricing for this item
  Map<String, double> pricing = calculateProductPricing(
    product: product,
    quantity: item.quantity,
    goldRateProvider: goldRateProvider,
    calculationContext: "OrderDetails - ${product.title}",
  );
  
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: UIColor.gold,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: TextStyle(
            color: UIColor.gold,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildDetailRow('Quantity:', '${item.quantity}'),
        _buildDetailRow('Weight per Unit:', '${product.weight.toStringAsFixed(2)} g'), 
        _buildDetailRow('Purity:', '${product.purity}'),
        _buildDetailRow('Total Weight:', '${(product.weight * item.quantity).toStringAsFixed(2)} g'),


        if (!isGoldPayment) ...[
         _buildDetailRow('Base Price:', CurrencyFormatter.formatAED(pricing['basePrice']!)),
         _buildDetailRow('Item Total:', CurrencyFormatter.formatAED(pricing['itemTotal']!)),
        ],
      ],
    ),
  );
}

Map<String, dynamic> get orderData {
  return {
    "bookingData": widget.order.items.map((item) => {
      "productId": item.productId.id,
      "quantity": item.quantity,
    }).toList(),
  };
}

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: UIColor.gold.withOpacity(0.8), 
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: UIColor.gold,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _showRejectDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Reject',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _showApproveDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UIColor.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Approve',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'Approve Order',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Are you sure you want to approve this order? This will fix the current gold rates for all items.',
        style: TextStyle(color: Colors.grey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () async {
            // Get the navigator first
            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            
            // Close the dialog first
            navigator.pop();
            
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: CircularProgressIndicator(
                  color: UIColor.gold,
                ),
              ),
            );

            try {
              // Get userId from LocalStorage
              final userId = await LocalStorage.getString('userId') ?? '';
              
              if (userId.isEmpty) {
                navigator.pop(); // Close loading dialog
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('User ID not found. Please login again.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Get provider references
              final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
              final goldRateProvider = Provider.of<GoldRateProvider>(context, listen: false);
              final pendingProvider = Provider.of<PendingOrdersProvider>(context, listen: false);

              dev.log('🚀 === STARTING APPROVAL WITH FIX PRICE PROCESS ===');
              dev.log('Order ID: ${widget.order.id}');
              dev.log('Total Items: ${widget.order.items.length}');
              dev.log('Gold Rate Connected: ${goldRateProvider.isConnected}');
              dev.log('Current Gold Data: ${goldRateProvider.goldData}');

              // STEP 1: Prepare fix price payload with current live rates
              List<Map<String, dynamic>> fixPriceBookingData = [];
              
              dev.log('🔧 === STEP 1: PREPARING FIX PRICE DATA ===');
              
              for (var orderItem in widget.order.items) {
                String productId = orderItem.productId.id;
                int quantity = orderItem.quantity;

                dev.log('Processing item: ProductId=$productId, Quantity=$quantity');

                Product? product = getProductById(productId, productViewModel);
                if (product == null) {
                  throw Exception("Product not found: $productId");
                }

                dev.log('Found Product: ${product.title}, Weight: ${product.weight}g, MakingCharge: ${product.makingCharge}');

                // Calculate current live price using the same calculation as DeliveryDetailsView
                Map<String, double> currentPricing = calculateProductPricing(
                  product: product,
                  quantity: 1, // Fix price per unit first
                  goldRateProvider: goldRateProvider,
                  calculationContext: "FIX_PRICE_APPROVAL for $productId",
                );

                double currentUnitPrice = currentPricing['unitPrice']!;
                dev.log('Calculated Unit Price: $currentUnitPrice AED');

                // Add each unit separately for fix price (same as DeliveryDetailsView)
                for (int i = 0; i < quantity; i++) {
                  final fixPriceItem = {
                    "productId": productId,
                    "fixedPrice": currentUnitPrice.round(), // Round to integer as per API
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

              // STEP 2: Call fix price API
              dev.log('🔒 === STEP 2: CALLING FIX PRICE API ===');
              final fixPriceResult = await productViewModel.fixPrice(fixPricePayload);

              dev.log('Fix Price API Response: ${fixPriceResult.toString()}');

              // Check fix price success
              if (fixPriceResult == null || 
                  fixPriceResult.message == null || 
                  !fixPriceResult.message!.toLowerCase().contains('fixed successfully')) {
                dev.log('❌ FIX PRICE FAILED');
                dev.log('Error Message: ${fixPriceResult?.message}');
                
                navigator.pop(); // Close loading dialog
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(fixPriceResult?.message ?? 'Failed to fix price'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              dev.log('✅ PRICE FIXED SUCCESSFULLY');
              dev.log('Fix Price Result: ${fixPriceResult.message}');

              // STEP 3: Approve all items with fixed prices
              dev.log('✅ === STEP 3: APPROVING ORDER ITEMS ===');
              
              bool approvalSuccess = true;
              
              // Create a map to track fixed prices by product
              Map<String, double> fixedPricesByProduct = {};
              int fixPriceIndex = 0;
              
              for (var orderItem in widget.order.items) {
                String productId = orderItem.productId.id;
                int quantity = orderItem.quantity;
                
                // Get the fixed price for this product (first occurrence)
                if (!fixedPricesByProduct.containsKey(productId) && fixPriceIndex < fixPriceBookingData.length) {
                  fixedPricesByProduct[productId] = fixPriceBookingData[fixPriceIndex]['fixedPrice'].toDouble();
                }
                
                double fixedUnitPrice = fixedPricesByProduct[productId] ?? orderItem.fixedPrice;
                
                dev.log('Approving item: ProductId=$productId, Quantity=$quantity, FixedPrice=$fixedUnitPrice');
                
                final itemSuccess = await pendingProvider.approveOrderItem(
                  orderId: widget.order.id,
                  itemId: orderItem.id,
                  userId: userId,
                  quantity: quantity,
                  fixedPrice: fixedUnitPrice, // Use the newly fixed price
                  productWeight: orderItem.productWeight,
                );
                
                if (!itemSuccess) {
                  approvalSuccess = false;
                  dev.log('❌ Failed to approve item: ${orderItem.id}');
                  break;
                } else {
                  dev.log('✅ Successfully approved item: ${orderItem.id}');
                }
                
                // Move to next fixed price entries
                fixPriceIndex += quantity;
              }

              navigator.pop(); // Close loading dialog

              if (approvalSuccess) {
                dev.log('🎉 === ORDER APPROVAL COMPLETED SUCCESSFULLY ===');
                navigator.pop(); // Go back to previous screen
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Order approved successfully with current gold rates'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                dev.log('❌ === ORDER APPROVAL FAILED ===');
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to approve order after fixing prices. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              
            } catch (e, stackTrace) {
              dev.log('💥 === CRITICAL ERROR IN APPROVAL PROCESS ===');
              dev.log('Error: ${e.toString()}');
              dev.log('Stack Trace: ${stackTrace.toString()}');
              
              navigator.pop(); // Close loading dialog
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Approval failed: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text(
            'Approve',
            style: TextStyle(color: UIColor.gold),
          ),
        ),
      ],
    ),
  );
}

void _showRejectDialog(BuildContext context) {
  final TextEditingController reasonController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'Reject Order',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure you want to reject this order?',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Rejection Reason',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: UIColor.gold),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (reasonController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please provide a rejection reason'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Get the navigator first
            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            
            // Close the dialog first
            navigator.pop();
            
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: CircularProgressIndicator(
                  color: UIColor.gold,
                ),
              ),
            );

            try {
              // Get userId from LocalStorage
              final userId = await LocalStorage.getString('userId') ?? '';
              
              if (userId.isEmpty) {
                navigator.pop(); // Close loading dialog
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('User ID not found. Please login again.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Get provider reference
              final provider = Provider.of<PendingOrdersProvider>(context, listen: false);
              bool success = true;
              
              // Reject all items in the order
              for (final item in widget.order.items) {
                final itemSuccess = await provider.rejectOrderItem(
                  orderId: widget.order.id,
                  itemId: item.id,
                  userId: userId,
                  rejectionReason: reasonController.text.trim(),
                );
                if (!itemSuccess) {
                  success = false;
                  break; // Stop on first failure
                }
              }

              navigator.pop(); // Close loading dialog

              if (success) {
                navigator.pop(); // Go back to previous screen
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Order rejected successfully'), 
                    backgroundColor: Colors.green, 
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to reject order. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              navigator.pop(); // Close loading dialog
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text(
            'Reject',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
}

extension on OrderItem {
  operator [](String other) {}
} 

class MockWidget {
  final Map<String, dynamic> orderData;
  MockWidget({required this.orderData});
}