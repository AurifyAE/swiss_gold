// lib/app/modules/bank/views/bank_details_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:fxg_app/app/widgets/global/custom_appbar.dart';
import 'package:provider/provider.dart';

import '../../core/models/bank_model.dart';
import '../../core/services/bank_service.dart';
import '../../core/utils/colors.dart';
// import '../providers/bank_provider.dart';
// import '../models/bank_model.dart';
 
class BankDetailsView extends StatelessWidget {
  const BankDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BankProvider(),
      child: BankDetailsScaffold(), 
    );
  }
}

// Wrapper scaffold to handle SnackBar globally
class BankDetailsScaffold extends StatefulWidget {
  const BankDetailsScaffold({super.key});

  @override
  State<BankDetailsScaffold> createState() => _BankDetailsScaffoldState();
}

class _BankDetailsScaffoldState extends State<BankDetailsScaffold> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              'Bank Details',
              style: TextStyle(
                fontFamily: 'Familiar',
                color: UIColor.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: UIColor.gold),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: UIColor.gold),
                onPressed: () {
                  final provider = context.read<BankProvider>();
                  provider.fetchBankDetails();
                },
              ),
            ],
          ),
          body: BankDetailsContent(scaffoldMessengerKey: _scaffoldMessengerKey),
        ),
      ),
    );
  }
}

class BankDetailsContent extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  
  const BankDetailsContent({super.key, required this.scaffoldMessengerKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<BankProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFd4ac6b)),
          ));
        }
        
        if (provider.isRequestingAdmin) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFd4ac6b)),
                ),
                SizedBox(height: 20),
                Text(
                  'Sending request to admin...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }
        
        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${provider.errorMessage}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor.gold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => provider.fetchBankDetails(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }
        
        // Check for request sent status and show snackbar
        if (provider.requestSent) {
          // Use a post-frame callback to show the SnackBar after the build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(provider.requestMessage),
                backgroundColor: Colors.black87,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: UIColor.gold, width: 1),
                ),
                duration: const Duration(seconds: 4),
              ),
            );
            // Reset the requestSent flag after showing the SnackBar
            Future.delayed(const Duration(milliseconds: 100), () {
              if (context.mounted) {
                context.read<BankProvider>().resetRequestSent();
              }
            });
          });
        }
        
        if (provider.bankResponse == null || provider.bankResponse!.bankInfo.bankDetails.isEmpty) {
          return EmptyBankDetailsWidget(
            provider: provider,
            scaffoldMessengerKey: scaffoldMessengerKey,
          );
        }
        
        final bankDetails = provider.bankResponse!.bankInfo.bankDetails;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bankDetails.length,
          itemBuilder: (context, index) {
            return BankCard(bankDetails: bankDetails[index]);
          },
        );
      },
    );
  }
}

class EmptyBankDetailsWidget extends StatelessWidget {
  final BankProvider provider;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  
  const EmptyBankDetailsWidget({
    super.key, 
    required this.provider,
    required this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
              border: Border.all(color: UIColor.gold, width: 1),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: UIColor.gold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Bank Details Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You don\'t have any bank details set up yet. Request an admin to add your bank details.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIColor.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              try {
                await provider.requestAdminToAddBankDetails();
              } catch (e) {
                // Handle unexpected errors
                scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('An unexpected error occurred: $e'),
                    backgroundColor: Colors.red.shade900,
                  ),
                );
              }
            },
            child: const Text(
              'Request Admin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class BankCard extends StatelessWidget {
  final BankDetails bankDetails;
  
  const BankCard({super.key, required this.bankDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UIColor.gold, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank Logo and Name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: UIColor.gold, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://api.aurify.ae${bankDetails.logo}', 
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) { 
                      return Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8), 
                        ),
                        child: Icon(
                          Icons.account_balance, 
                          color: UIColor.gold,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bankDetails.bankName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: UIColor.gold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account Holder: ${bankDetails.holderName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bank Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(context, 'Account Number', bankDetails.accountNumber, true),
                _buildDetailRow(context, 'IBAN', bankDetails.iban, true),
                _buildDetailRow(context, 'IFSC Code', bankDetails.ifsc, false),
                _buildDetailRow(context, 'SWIFT Code', bankDetails.swift, false),
                _buildDetailRow(context, 'Branch', bankDetails.branch, false),
                _buildDetailRow(context, 'City', bankDetails.city, false),
                _buildDetailRow(context, 'Country', bankDetails.country, false),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(BuildContext context, String label, String value, bool canCopy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: UIColor.gold,
                    ),
                  ),
                ),
                Visibility(
                  visible: canCopy,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      // Use the nearest ScaffoldMessenger
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied to clipboard'),
                          backgroundColor: Colors.black87,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: UIColor.gold, width: 1),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 20,
                      color: UIColor.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}