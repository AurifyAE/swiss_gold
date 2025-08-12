import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/view_models/pending_provider.dart';
import '../../core/services/local_storage.dart'; // Add this import for LocalStorage
import 'order_details_screen.dart';
import 'widgets/pending_order_card.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchOrders();
  }

  Future<void> _loadUserIdAndFetchOrders() async {
    userId = await LocalStorage.getString('userId') ?? '';
    if (mounted) {
      Provider.of<PendingOrdersProvider>(context, listen: false)
          .fetchPendingOrders(userId);
    }
  }

  Future<void> _refreshOrders() async {
    if (userId.isEmpty) {
      userId = await LocalStorage.getString('userId') ?? '';
    }
    return Provider.of<PendingOrdersProvider>(context, listen: false)
        .fetchPendingOrders(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: const Text(
      //     'Pending Approvals',
      //     style: TextStyle(
      //       color: Color(0xFFD4AF37),
      //       fontSize: 20,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: SafeArea( 
        child: Consumer<PendingOrdersProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                ),
              );
            }
        
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        provider.clearError();
                        await _refreshOrders();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
        
            if (provider.pendingOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pending_actions,
                      color: Colors.grey[600],
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Pending Approvals',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All your orders have been processed',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
        
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              color: const Color(0xFFD4AF37),
              backgroundColor: Colors.grey[900],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.pendingOrders.length,
                itemBuilder: (context, index) {
                  final order = provider.pendingOrders[index];
                  return PendingOrderCard(
                    order: order,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(order: order),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}