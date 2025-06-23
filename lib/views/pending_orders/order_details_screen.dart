import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';

import '../../core/models/pending_order_model.dart';
import '../../core/services/local_storage.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/view_models/pending_provider.dart';

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

  Widget _buildOrderSummaryCard() {
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
            'Order Summary',
            style: TextStyle(
              color: UIColor.gold,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
                  'Live rate: ${CurrencyFormatter.getCurrentRate()}',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Amount: ${CurrencyFormatter.formatAED(widget.order.totalPrice)}',
                  style: TextStyle(
                    color: UIColor.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
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
          _buildDetailRow('Total Amount:', CurrencyFormatter.formatAED(widget.order.totalPrice)),
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
            item.productId.title,
            style: TextStyle(
              color: UIColor.gold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow('Quantity:', '${item.quantity}'),
          _buildDetailRow('Weight per Unit:', '${item.productWeight.toStringAsFixed(2)} g'),
          _buildDetailRow('Purity:', '${item.productId.purity}'),
          _buildDetailRow('Total Weight:', '${item.productWeight.toStringAsFixed(2)} g'),
          _buildDetailRow('Base Price:', CurrencyFormatter.formatAED(item.fixedPrice)),
          _buildDetailRow('Item Total:', CurrencyFormatter.formatAED(item.fixedPrice + item.makingCharge)),
        ],
      ),
    );
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
              color: Colors.grey[300],
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
        'Are you sure you want to approve this order?',
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

              // Get provider reference
              final provider = Provider.of<PendingOrdersProvider>(context, listen: false);
              bool success = true;
              
              // Approve all items in the order
              for (final item in widget.order.items) {
                final itemSuccess = await provider.approveOrderItem(
                  orderId: widget.order.id,
                  itemId: item.id,
                  userId: userId,
                  quantity: item.quantity,
                  fixedPrice: item.fixedPrice,
                  productWeight: item.productWeight,
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
                    content: Text('Order approved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to approve order. Please try again.'),
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
                    backgroundColor: Colors.red,
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