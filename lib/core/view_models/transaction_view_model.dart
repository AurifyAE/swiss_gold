import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/services/transaction_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/services/local_storage.dart';

class TransactionViewModel extends ChangeNotifier {
  late TransactionService _transactionService;
  
  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  
  ViewState _paginationState = ViewState.idle;
  ViewState get paginationState => _paginationState;
  
  TransactionData? _transactionData;
  TransactionData? get transactionData => _transactionData;
  
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;
  
  BalanceInfo? get balanceInfo => _transactionData?.balanceInfo;
  Summary? get summary => _transactionData?.summary;
  Pagination? get pagination => _transactionData?.pagination;
  
  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;
  
  bool _isAscending = false;
  bool get isAscending => _isAscending;
  
  bool get loadingMore => _paginationState == ViewState.loadingMore;
  
  bool _isGuest = false;
  bool get isGuest => _isGuest;
  
  // Simplified constructor - no longer needs UserModel
  TransactionViewModel() {
    _transactionService = TransactionService();
    log('TransactionViewModel initialized with new TransactionService');
    checkGuestMode();
  }
  
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
  
  void toggleSortOrder() {
    _isAscending = !_isAscending;
    
    // Sort transactions based on date
    _transactions.sort((a, b) {
      return _isAscending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt);
    });
    
    notifyListeners();
  }
  
  List<Transaction> get filteredTransactions {
    if (_selectedFilter == 'All') {
      return _transactions;
    } else if (_selectedFilter == 'Gold') {
      return _transactions.where((t) => t.balanceType == 'GOLD').toList();
    } else if (_selectedFilter == 'Cash') {
      return _transactions.where((t) => t.balanceType == 'CASH').toList();
    } else if (_selectedFilter == 'Credit') {
      return _transactions.where((t) => t.type == 'CREDIT').toList();
    } else if (_selectedFilter == 'Debit') {
      return _transactions.where((t) => t.type == 'DEBIT').toList();
    }
    return _transactions;
  }
  
  Future<void> fetchTransactions() async {
    _state = ViewState.loading;
    notifyListeners();
    
    try {
      final response = await _transactionService.fetchTransactions();
      
      if (response != null && response.success) {
        _transactionData = response.data;
        _transactions = response.data.transactions;
        
        // Sort transactions by default (newest first)
        if (!_isAscending) {
          _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
        
        _state = ViewState.idle;
      } else {
        _state = ViewState.error;
      }
    } catch (e) {
      log('Error in transaction view model: $e');
      _state = ViewState.error;
    }
    
    notifyListeners();
  }
  
  Future<void> loadMoreTransactions() async {
    if (_transactionData == null || 
        _paginationState == ViewState.loadingMore ||
        (pagination != null && pagination!.currentPage >= pagination!.totalPages)) {
      return;
    }
    
    _paginationState = ViewState.loadingMore;
    notifyListeners();
    
    try {
      final nextPage = pagination!.currentPage + 1;
      final response = await _transactionService.fetchTransactions(page: nextPage);
      
      if (response != null && response.success) {
        _transactionData = response.data;
        
        // Sort new transactions based on current sort order before adding
        final newTransactions = response.data.transactions;
        if (!_isAscending) {
          newTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          newTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
        
        _transactions.addAll(newTransactions);
        _paginationState = ViewState.idle;
      } else {
        _paginationState = ViewState.error;
      }
    } catch (e) {
      log('Error loading more transactions: $e');
      _paginationState = ViewState.error;
    }
    
    notifyListeners();
  }
  
  Future<void> checkGuestMode() async {
    try {
      _isGuest = await LocalStorage.getBool('isGuest') ?? false;
      log('Guest mode: $_isGuest');
    } catch (e) {
      log('Error checking guest mode: ${e.toString()}');
      _isGuest = false;
    }
    notifyListeners();
  }
  
  Future<Transaction?> fetchTransactionById(String transactionId) async {
    try {
      return await _transactionService.fetchTransactionById(transactionId);
    } catch (e) {
      log('Error fetching transaction details: $e');
      return null;
    }
  }
  
  Future<BalanceInfo?> fetchBalance() async {
    try {
      return await _transactionService.fetchBalance();
    } catch (e) {
      log('Error fetching balance: $e');
      return null;
    }
  }
  
  Future<Summary?> fetchTransactionSummary() async {
    try {
      return await _transactionService.fetchTransactionSummary();
    } catch (e) {
      log('Error fetching transaction summary: $e');
      return null;
    }
  }
  
  void refreshTransactions() {
    _transactions = [];
    fetchTransactions();
  }
}