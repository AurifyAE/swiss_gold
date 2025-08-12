// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:swiss_gold/views/pending_orders/pending_approval_screen.dart';

import '../../../core/models/notification_model.dart';
import '../../../core/models/pending_order_model.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/notification_provider.dart';
import '../../../core/view_models/pending_provider.dart';
import '../../pending_orders/order_details_screen.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMMM d, y • h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notification Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final NotificationModel? notification = provider.getNotificationById(notificationId);
          
          if (notification == null) {
            return const Center(
              child: Text(
                'Notification not found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // Extract order ID from message if present
          String? orderId = notification.orderId;
          if (orderId == null) {
            RegExp orderRegex = RegExp(r'#([A-Za-z0-9-]+)');
            final match = orderRegex.firstMatch(notification.message);
            if (match != null && match.groupCount >= 1) {
              orderId = match.group(1);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and status
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: _getNotificationIcon(notification),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Read/Unread status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: notification.read
                                    ? Colors.grey.withOpacity(0.2)
                                    : Colors.amber.shade700.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                notification.read ? 'Read' : 'Unread',
                                style: TextStyle(
                                  color: notification.read ? Colors.grey : Colors.amber.shade300,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            
                            // Type badge if available
                            if (notification.type != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(notification.type!).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _formatType(notification.type!),
                                  style: TextStyle(
                                    color: _getTypeColor(notification.type!),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(notification.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                
                
                // Notification content (make it tappable if Approval-Pending)
                GestureDetector(
                  onTap: notification.type == 'user_approvel_pending' 
                      ? () async {
                          // Fetch the PendingOrder using orderId
                          final pendingProvider = Provider.of<PendingOrdersProvider>(context, listen: false);
                          final PendingOrder? order = pendingProvider.getOrderById(orderId!);

                          // if (order != null) {
                          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(
                                builder: (_) =>PendingApprovalScreen() , 
                                
                              ), (route) => true,); 
                            // Navigator.pushAndRemoveUntil(

                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) =>PendingApprovalScreen() , 
                            //   ),
                            // );
                          // } else {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text('Order not found'),
                          //       backgroundColor: Colors.red,
                          //     ),
                          //   );
                          // }
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: notification.type == 'Approval-Pending'
                                  ? Colors.amber.shade300
                                  : Colors.white,
                              decoration: notification.type == 'Approval-Pending'
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                          // if (orderId != null || notification.orderId != null) ...[
                          //   const SizedBox(height: 24),
                          //   const Divider(
                          //     color: Colors.white24,
                          //     height: 1,
                          //   ),
                          //   const SizedBox(height: 16),
                          //   Row(
                          //     children: [
                          //       const Text(
                          //         'Order ID:',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 16,
                          //           color: Colors.white70,
                          //         ),
                          //       ),
                          //       const SizedBox(width: 8),
                          //       Container(
                          //         padding: const EdgeInsets.symmetric(
                          //           horizontal: 10,
                          //           vertical: 4,
                          //         ),
                          //         decoration: BoxDecoration(
                          //           color: Colors.amber.shade700.withOpacity(0.1),
                          //           borderRadius: BorderRadius.circular(8),
                          //         ),
                          //         child: Text(
                          //           orderId ?? notification.orderId!,
                          //           style: TextStyle(
                          //             fontSize: 16,
                          //             color: Colors.amber.shade300,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ],
                          
                          // Display item ID if available
                          // if (notification.itemId != null) ...[
                          //   const SizedBox(height: 12),
                          //   Row(
                          //     children: [
                          //       const Text(
                          //         'Item ID:',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 16,
                          //           color: Colors.white70,
                          //         ),
                          //       ),
                          //       const SizedBox(width: 8),
                          //       Container(
                          //         padding: const EdgeInsets.symmetric(
                          //           horizontal: 10,
                          //           vertical: 4,
                          //         ),
                          //         decoration: BoxDecoration(
                          //           color: Colors.blue.shade700.withOpacity(0.1),
                          //           borderRadius: BorderRadius.circular(8),
                          //         ),
                          //         child: Text(
                          //           notification.itemId!,
                          //           style: TextStyle(
                          //             fontSize: 16,
                          //             color: Colors.blue.shade300,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action buttons based on notification type
                if (notification.type == 'Approval-Pending') ...[
                  // Delete button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey.shade900,
                            title: const Text(
                              'Delete Notification',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this notification?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.amber.shade300),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ) ?? false;
                        
                        if (shouldDelete) {
                          final success = await provider.deleteNotification(notification.id);
                          
                          if (success) {
                            Navigator.pop(context);
                            
                            // Show success snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Notification deleted'),
                                backgroundColor: Colors.green.shade700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // Show error snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Failed to delete notification'),
                                backgroundColor: Colors.red.shade700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.white,),
                      label: const Text('Delete Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                 
                 
                ] else ...[
                  // Regular delete button for non-approval notifications
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey.shade900,
                            title: const Text(
                              'Delete Notification',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this notification?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.amber.shade300),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ) ?? false;
                        
                        if (shouldDelete) {
                          final success = await provider.deleteNotification(notification.id);
                          
                          if (success) {
                            Navigator.pop(context);
                            
                            // Show success snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Notification deleted'),
                                backgroundColor: Colors.green.shade700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // Show error snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Failed to delete notification'),
                                backgroundColor: Colors.red.shade700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.white,),
                      label: const Text('Delete Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _getNotificationIcon(NotificationModel notification) {
    IconData iconData;
    Color iconColor;
    
    if (notification.type == 'Order') {
      iconData = Icons.shopping_bag_outlined;
      iconColor = Colors.amber.shade300;
    } else if (notification.type == 'Payment') {
      iconData = Icons.payment_outlined;
      iconColor = Colors.green.shade300;
    } else if (notification.type == 'Account') {
      iconData = Icons.person_outline;
      iconColor = Colors.blue.shade300;
    } else if (notification.type == 'Approval-Pending') {
      iconData = Icons.pending_outlined;
      iconColor = Colors.orange.shade300;
    } else if (notification.type == 'System') {
      iconData = Icons.info_outline;
      iconColor = Colors.purple.shade300;
    } else {
      iconData = Icons.notifications_outlined;
      iconColor = Colors.amber.shade300;
    }
    
    return Icon(
      iconData,
      color: iconColor,
      size: 28,
    );
  }
  
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Order':
        return Colors.amber.shade300;
      case 'Payment':
        return Colors.green.shade300;
      case 'Account':
        return Colors.blue.shade300;
      case 'Approval-Pending':
        return Colors.orange.shade300;
      case 'System':
        return Colors.purple.shade300;
      default:
        return Colors.amber.shade300;
    }
  }
  
  String _formatType(String type) {
    if (type == 'Approval-Pending') {
      return 'Approval';
    }
    return type;
  }
}