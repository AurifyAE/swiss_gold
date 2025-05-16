// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// // import 'package:swiss_gold/core/providers/gold_rate_provider.dart';

// import 'core/services/server_provider.dart'; // Import the GoldRateProvider we created

// class GoldDetailsScreen extends StatefulWidget {
//   @override
//   _GoldDetailsScreenState createState() => _GoldDetailsScreenState();
// }

// class _GoldDetailsScreenState extends State<GoldDetailsScreen> {
//   bool _isRefreshing = false;

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize data fetch on screen load
//     Future.microtask(() {
//       final provider = Provider.of<GoldRateProvider>(context, listen: false);
//       if (!provider.isConnected || provider.goldData == null) {
//         provider.initializeConnection();
//       }
//     });
//   }

//   // Function to manually refresh gold data
//   Future<void> _refreshGoldData() async {
//     setState(() {
//       _isRefreshing = true;
//     });
    
//     try {
//       final provider = Provider.of<GoldRateProvider>(context, listen: false);
//       await provider.refreshGoldData();
//     } catch (e) {
//       log("Error refreshing gold data: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isRefreshing = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Gold Details"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _isRefreshing ? null : _refreshGoldData,
//           ),
//         ],
//       ),
//       body: Consumer<GoldRateProvider>(
//         builder: (context, provider, child) {
//           log("🔄 UI Rebuilt with goldData: ${provider.goldData}");
          
//           // Show loading indicator when connecting or refreshing
//           if (provider.isLoading || _isRefreshing) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text("Loading gold data..."),
//                 ],
//               ),
//             );
//           }
          
//           // Show message if not connected
//           if (!provider.isConnected) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.signal_wifi_off, size: 48, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text("Not connected to server"),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () => provider.reconnect(),
//                     child: Text("Reconnect"),
//                   ),
//                 ],
//               ),
//             );
//           }
          
//           // Show message if no data available
//           if (provider.goldData == null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, size: 48, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text("No gold data available"),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () => provider.requestGoldData(),
//                     child: Text("Fetch Gold Data"),
//                   ),
//                 ],
//               ),
//             );
//           }
          
//           // Display gold data when available
//           final goldData = provider.goldData!;
//           return RefreshIndicator(
//             onRefresh: _refreshGoldData,
//             child: SingleChildScrollView(
//               physics: AlwaysScrollableScrollPhysics(),
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildGoldInfoCard(goldData),
//                   SizedBox(height: 16),
//                   _buildGoldPriceCard(goldData),
//                   SizedBox(height: 16),
//                   _buildMarketDetailsCard(goldData),
//                   SizedBox(height: 16),
//                   Text(
//                     "Last Updated: ${_formatTimestamp(goldData['timestamp'])}",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Format timestamp for display
//   String _formatTimestamp(dynamic timestamp) {
//     if (timestamp == null) return "N/A";
    
//     try {
//       if (timestamp is String) {
//         final dateTime = DateTime.parse(timestamp);
//         return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
//       } else if (timestamp is int) {
//         final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
//         return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
//       }
//     } catch (e) {
//       log("Error formatting timestamp: $e");
//     }
    
//     return timestamp.toString();
//   }

//   // Gold info card widget
//   Widget _buildGoldInfoCard(Map<String, dynamic> goldData) {
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.verified, color: Colors.amber),
//                 SizedBox(width: 8),
//                 Text(
//                   "Gold",
//                   style: TextStyle(
//                     fontSize: 24, 
//                     fontWeight: FontWeight.bold,
//                     color: Colors.amber.shade800,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Symbol: ${goldData['symbol'] ?? 'XAU'}",
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Gold price card widget
//   Widget _buildGoldPriceCard(Map<String, dynamic> goldData) {
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Current Prices",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Divider(),
//             SizedBox(height: 8),
//             _buildPriceRow("Bid Price", goldData['bid']?.toString() ?? "N/A", Colors.green),
//             SizedBox(height: 12),
//             _buildPriceRow("Ask Price", goldData['ask']?.toString() ?? "N/A", Colors.red),
//           ],
//         ),
//       ),
//     );
//   }

//   // Market details card widget
//   Widget _buildMarketDetailsCard(Map<String, dynamic> goldData) {
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Market Details",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Divider(),
//             SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildDetailBox("High", goldData['high']?.toString() ?? "N/A", Colors.green),
//                 SizedBox(width: 16),
//                 _buildDetailBox("Low", goldData['low']?.toString() ?? "N/A", Colors.red),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper widget for price rows
//   Widget _buildPriceRow(String label, String value, Color valueColor) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: 16),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: valueColor,
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper widget for detail boxes
//   Widget _buildDetailBox(String label, String value, Color valueColor) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: valueColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }