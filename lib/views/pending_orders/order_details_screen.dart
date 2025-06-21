import 'package:flutter/material.dart';

import '../../core/models/pending_order_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
// import '../models/pending_order_model.dart';
// import '../utils/date_formatter.dart';
// import '../utils/currency_formatter.dart';
// import '../widgets/product_image_carousel.dart';

class OrderDetailsScreen extends StatelessWidget {
  final PendingOrder order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Color(0xFFD4AF37),
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
        // color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: Color(0xFFD4AF37),
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
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'User Approval Pending',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
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
                  'Total Amount: ${CurrencyFormatter.formatAED(order.totalPrice)}',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
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
        // color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow('Payment Method:', order.paymentMethod),
          _buildDetailRow('Delivery Date:', DateFormatter.formatDeliveryDate(order.orderDate)),
          _buildDetailRow('Total Items:', '${order.items.length}'),
          _buildDetailRow('Total Amount:', CurrencyFormatter.formatAED(order.totalPrice)),
        ],
      ),
    );
  }

  Widget _buildProductDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Details',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => _buildProductItem(item)).toList(),
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
          color: const Color(0xFFD4AF37).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Images
          // if (item.productId.images.isNotEmpty)
          //   ProductImageCarousel(images: item.productId.images),
          // const SizedBox(height: 12),
          
          Text(
            item.productId.title,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
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
            style: const TextStyle(
              color: Color(0xFFD4AF37),
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
              // Handle reject action
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
              // Handle approve action
              _showApproveDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
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

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // backgroundColor: Colors.grey[900],
        title: const Text(
          'Reject Order',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to reject this order?',
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
            onPressed: () {
              Navigator.pop(context);
              // Handle reject logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order rejected successfully'),
                  backgroundColor: Colors.red,
                ),
              );
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

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // backgroundColor: Colors.grey[900],
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
            onPressed: () {
              Navigator.pop(context);
              // Handle approve logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Approve',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/widgets/product_image_carousel.dart
// import 'package:flutter/material.dart';
// import '../models/pending_order_model.dart';

// class ProductImageCarousel extends StatefulWidget {
//   final List<ProductImage> images;

//   const ProductImageCarousel({
//     Key? key,
//     required this.images,
//   }) : super(key: key);

//   @override
//   State<ProductImageCarousel> createState() => _ProductImageCarouselState();
// }

// class _ProductImageCarouselState extends State<ProductImageCarousel> {
//   int _currentIndex = 0;
//   final PageController _pageController = PageController();

//   @override
//   Widget build(BuildContext context) {
//     if (widget.images.isEmpty) {
//       return Container(
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.grey[800],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Icon(
//             Icons.image_not_supported,
//             color: Colors.grey,
//             size: 48,
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: const Color(0xFFD4AF37).withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: PageView.builder(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               itemCount: widget.images.length,
//               itemBuilder: (context, index) {
//                 return Image.network(
//                   widget.images[index].url,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       color: Colors.grey[800],
//                       child: const Center(
//                         child: Icon(
//                           Icons.image_not_supported,
//                           color: Colors.grey,
//                           size: 48,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//         if (widget.images.length > 1) ...[
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: widget.images.asMap().entries.map((entry) {
//               return Container(
//                 width: 8,
//                 height: 8,
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _currentIndex == entry.key 
//                       ? const Color(0xFFD4AF37)
//                       : Colors.grey[600],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }
