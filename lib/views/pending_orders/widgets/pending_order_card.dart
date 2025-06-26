import 'package:flutter/material.dart';
import 'package:swiss_gold/core/utils/colors.dart';

import '../../../core/models/pending_order_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class PendingOrderCard extends StatelessWidget {
  final PendingOrder order;
  final VoidCallback onTap;

  const PendingOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            // color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: UIColor.gold,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.transactionId}',
                            style:  TextStyle( 
                              color: UIColor.gold, 
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatOrderDate(order.orderDate),
                            style: TextStyle(
                              color: UIColor.gold.withOpacity(0.8) ,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (order.items.isNotEmpty && order.items.first.productId.images.isNotEmpty)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: UIColor.gold, 
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order.items.first.productId.images.first.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: UIColor.gold.withOpacity(0.8),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: UIColor.gold,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.items.isNotEmpty ? order.items.first.productId.title : 'Unknown Product',
                            style:  TextStyle(
                              color: UIColor.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: UIColor.gold.withOpacity(0.5) , 
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Weight: ${order.totalWeight.toStringAsFixed(2)} g',
                            style: TextStyle(
                              color: UIColor.gold.withOpacity(0.5), 
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,  
                      // mainAxisAlignment: MainAxisAlignment.start,   
                      children: [
                        
                        Text(
                          order.paymentMethod,
                          style: TextStyle(
                            color: UIColor.gold.withOpacity(0.6) , 
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                 Divider( 
                  color: UIColor.gold,
                  thickness: 0.5,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        color: UIColor.gold.withOpacity(0.6), 
                        fontSize: 12,
                      ),
                    ),
                     Icon(
                      Icons.arrow_forward_ios,
                      color: UIColor.gold, 
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}