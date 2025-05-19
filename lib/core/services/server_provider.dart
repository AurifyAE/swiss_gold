import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/services/secrete_key.dart';
// import 'package:swiss_gold/services/spot_rate_service.dart';
// import 'package:swiss_gold/models/spot_rate_model.dart';

import '../models/spot_rate_model.dart';
import '../utils/endpoint.dart';
import 'spotrate_service.dart';

class GoldRateProvider extends ChangeNotifier {
  IO.Socket? _socket;
  Map<String, dynamic>? _goldData;
  String _serverLink = 'https://capital-server-gnsu.onrender.com';
  bool _isConnected = false;
  bool _isLoading = false;
  
  // Add properties for spot rate data
  SpotRateModel? _spotRateData;
  String _adminId = ''; // This should be set from somewhere in your app

  // Getters
  Map<String, dynamic>? get goldData => _goldData;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  SpotRateModel? get spotRateData => _spotRateData;

  // Set admin ID
  set adminId(String id) {
    _adminId = id;
    // fetchSpotRates();
  }

  // Constructor
  GoldRateProvider() {
    initializeConnection();
  }

  // Initialize the connection to the Socket.IO server
  Future<void> initializeConnection() async {
    _isLoading = true;
    notifyListeners();
    
    dev.log('Initializing gold rate connection');
    
    try {
      final link = await fetchServerLink();
      if (link.isNotEmpty) {
        _serverLink = link;
      }
      await connectToSocket(link: _serverLink);
      
      // Fetch spot rates if admin ID is available
      // if (_adminId.isNotEmpty) {
      //   await fetchSpotRates();
      // }
    } catch (e) {
      dev.log("Error initializing connection: $e");
      await connectToSocket(link: _serverLink);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch server link from API
  Future<String> fetchServerLink() async {
    dev.log('Fetching server link');
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/get-server'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('info') && data['info'].containsKey('serverUrl')) {
          String serverUrl = data['info']['serverUrl'];
          dev.log('Received server link: $serverUrl');
          return serverUrl;
        }
      }
      dev.log('Using default server link: $_serverLink');
      return _serverLink;
    } catch (e) {
      dev.log("Error fetching server link: $e");
      return _serverLink;
    }
  }

  // Connect to socket and start listening for gold data
  Future<void> connectToSocket({required String link}) async {
    dev.log('Connecting to socket at: $link');
    try {
      _socket = IO.io(link, {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'reconnection': true,
        'query': {'secret': 'aurify@123'},
      });

      _socket?.onConnect((_) {
        dev.log("Socket connected successfully");
        _isConnected = true;
        notifyListeners();
        
        // Request only gold data
        requestGoldData();
      });

      _socket?.on('market-data', (data) {
        handleGoldData(data);
      });

      _socket?.onConnectError((data) {
        dev.log("Socket connection error: $data");
        _isConnected = false;
        notifyListeners();
      });

      _socket?.onDisconnect((_) {
        dev.log("Socket disconnected");
        _isConnected = false;
        attemptReconnection();
        notifyListeners();
      });

      _socket?.connect();
    } catch (e) {
      dev.log("Error connecting to socket: $e");
      attemptReconnection();
    }
  }

  // Handle market data specifically for Gold
  void handleGoldData(dynamic data) {
    try {
      if (data is Map<String, dynamic> && 
          data['symbol'] is String && 
          data['symbol'] == 'Gold') {
        
        // Process numerical values to ensure they're doubles
        Map<String, dynamic> processedData = Map<String, dynamic>.from(data);
        processedData.forEach((key, value) {
          if (value is num && value is! double) {
            processedData[key] = value.toDouble();
          }
        });
        
        _goldData = processedData;
        
        dev.log('Gold Rate Details:');
        dev.log('Bid: ${_goldData!['bid'] ?? 'N/A'}');
        dev.log('Ask: ${_goldData!['ask'] ?? 'N/A'}');
        dev.log('High: ${_goldData!['high'] ?? 'N/A'}');
        dev.log('Low: ${_goldData!['low'] ?? 'N/A'}');
        dev.log('Symbol: ${_goldData!['symbol'] ?? 'N/A'}');
        dev.log('Last Updated: ${_goldData!['timestamp'] ?? 'N/A'}');
        
        // Log calculated prices with the new formula if spot rate data is available
        if (_spotRateData != null) {
          double? bid = _goldData!['bid'] is num ? (_goldData!['bid'] as num).toDouble() : null;
          
          if (bid != null) {
            double biddingPrice = bid + _spotRateData!.goldBidSpread;
            double askingPrice = biddingPrice + _spotRateData!.goldAskSpread + 0.5;
            
            dev.log('Calculated Prices:');
            dev.log('Original Bid: $bid');
            dev.log('Bid Spread: ${_spotRateData!.goldBidSpread}');
            dev.log('Bidding Price: $biddingPrice (Bid + Bid Spread)');
            dev.log('Ask Spread: ${_spotRateData!.goldAskSpread}');
            dev.log('Asking Price: $askingPrice (Bidding Price + Ask Spread + 0.5)');
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      dev.log("Error handling gold data: $e");
    }
  }

  // Fetch spot rates from the server
  // Future<void> fetchSpotRates() async {
  //   if (_adminId.isEmpty) {
  //     dev.log('Admin ID not provided. Cannot fetch spot rates.');
  //     return;
  //   }
    
  //   dev.log('Fetching spot rates for admin ID: $_adminId');
  //   try {
  //     _spotRateData = await SpotRateService.getSpotRates(_adminId);
  //     dev.log('Spot rates fetched successfully. Ask Spread: ${_spotRateData?.goldAskSpread}, Bid Spread: ${_spotRateData?.goldBidSpread}');
      
  //     // Recalculate prices with new data
  //     if (_goldData != null) {
  //       // Log updated calculations
  //       double? bid = _goldData!['bid'] is num ? (_goldData!['bid'] as num).toDouble() : null;
        
  //       if (bid != null) {
  //         double biddingPrice = bid + _spotRateData!.goldBidSpread;
  //         double askingPrice = biddingPrice + _spotRateData!.goldAskSpread + 0.5;
          
  //         dev.log('Updated Calculated Prices:');
  //         dev.log('Original Bid: $bid');
  //         dev.log('Bidding Price: $biddingPrice (Bid + Bid Spread: ${_spotRateData!.goldBidSpread})');
  //         dev.log('Asking Price: $askingPrice (Bidding Price + Ask Spread: ${_spotRateData!.goldAskSpread} + 0.5)');
  //       }
  //     }
      
  //     notifyListeners();
  //   } catch (e) {
  //     dev.log('Error fetching spot rates: $e');
  //   }
  // }

  // Request only gold data from the server
  void requestGoldData() {
    try {
      _socket?.emit('request-data', [["Gold"]]);
      dev.log('Requested Gold data only');
    } catch (e) {
      dev.log('Error requesting Gold data: $e');
    }
  }

  // Calculate asking price using the formula: bid + bidspread = bidding price; bidding price + ask spread + 0.5 = asking price
  double? calculateAskingPrice() {
    if (_goldData == null || _spotRateData == null) {
      dev.log('Cannot calculate asking price: missing data');
      return null;
    }
    
    double? bid = _goldData!['bid'] is num ? (_goldData!['bid'] as num).toDouble() : null;
    
    if (bid == null) {
      dev.log('Cannot calculate asking price: bid is null');
      return null;
    }
    
    double biddingPrice = bid + _spotRateData!.goldBidSpread;
    double askingPrice = biddingPrice + _spotRateData!.goldAskSpread + 0.5;
    
    dev.log('Calculated asking price: $askingPrice');
    return askingPrice;
  }

  // Attempt to reconnect if connection is lost
  void attemptReconnection() {
    if (!_isConnected) {
      Future.delayed(Duration(seconds: 5), () {
        dev.log("Attempting to reconnect...");
        initializeConnection();
      });
    }
  }

  // Manual reconnect method
  void reconnect() {
    try {
      dev.log('Manual reconnection initiated');
      _socket?.disconnect();
      initializeConnection();
    } catch (e) {
      dev.log("Error during manual reconnection: $e");
    }
  }

  // Refresh gold data and spot rates
  Future<Map<String, dynamic>?> refreshGoldData() async {
    dev.log('Refreshing gold data');
    if (!_isConnected) {
      dev.log('Socket not connected. Initializing connection...');
      await initializeConnection();
      // Wait for the connection to establish
      await Future.delayed(Duration(seconds: 2));
    }
    
    // Refresh spot rates if admin ID is available
    // if (_adminId.isNotEmpty) {
    //   await fetchSpotRates();
    // }
    
    requestGoldData();
    
    // Wait a moment for data to arrive
    await Future.delayed(Duration(seconds: 2));
    return _goldData;
  }

  @override
  void dispose() {
    dev.log('Disposing GoldRateProvider');
    _socket?.disconnect();
    super.dispose();
  }
}