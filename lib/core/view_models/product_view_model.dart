import 'dart:developer';

import 'package:swiss_gold/core/models/market_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/models/product_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class ProductViewModel extends BaseModel {
  final List<Product> _productList = [];
  List<Product> get productList => _productList;

  ProductModel? _productModel;
  ProductModel? get productModel => _productModel;

  bool hasMoreData = true;
  bool isLoading = false;
  bool? _isGuest;
  num _totalQuantity = 0;
  num get totalQuantity => _totalQuantity;
  bool? get isGuest => _isGuest;

  Map<int, int> _productQuantities = {};
  Map<int, int> get productQuantities => _productQuantities;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  ViewState _marketPriceState = ViewState.idle;
  ViewState get marketPriceState => _marketPriceState;

  MarketModel? _marketModel;
  MarketModel? get marketModel => _marketModel;

  Map<String, dynamic>? _marketData;
  Map<String, dynamic>? get marketData => _marketData;

  double? _goldSpotRate;
  double? get goldSpotRate => _goldSpotRate;

  String? _adminId;
  String? _categoryId;
  String? _userSpotRateId;

  bool _hasCategoryId = false;
  bool _hasUserSpotRateId = false;

  String? get adminId => _adminId;
  String? get categoryId => _categoryId;
  String? get userSpotRateId => _userSpotRateId;

  bool get hasCategoryId => _hasCategoryId;
  bool get hasUserSpotRateId => _hasUserSpotRateId;

  ProductViewModel() {
    _initializeIds();
    checkGuestMode();
  }

  Future<void> _initializeIds() async {
    try {
      _adminId = '67f37dfe4831e0eb637d09f1';
      
      // Use the new category status check function
      final userStatus = await ProductService.checkCategoryStatus();
      _hasCategoryId = userStatus['hasCategoryId'];
      _hasUserSpotRateId = userStatus['hasUserSpotRateId'];
      _categoryId = _hasCategoryId ? userStatus['categoryId'] : '';
      _userSpotRateId = _hasUserSpotRateId ? userStatus['userSpotRateId'] : '';

      log('Initialized ProductViewModel with:');
      log('adminId: $_adminId');
      log('hasCategoryId: $_hasCategoryId, categoryId: $_categoryId');
      log('hasUserSpotRateId: $_hasUserSpotRateId, userSpotRateId: $_userSpotRateId');
    } catch (e) {
      log('Error initializing IDs: ${e.toString()}');
      _adminId = '';
      _categoryId = '';
      _userSpotRateId = '';
      _hasCategoryId = false;
      _hasUserSpotRateId = false;
    }
    notifyListeners();
  }

  Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    try {
      _messageModel = await ProductService.fixPrice(payload);
    } catch (e) {
      log('Error fixing price: ${e.toString()}');
    }
    setState(ViewState.idle);
    notifyListeners();
    return _messageModel;
  }

  void getTotalQuantity(Map<int, int> productQuantities) {
    _productQuantities = Map<int, int>.from(productQuantities);
    _totalQuantity =
        productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
    log("Total quantity: $_totalQuantity");
    notifyListeners();
  }

  void clearQuantities() {
    _productQuantities.clear();
    _totalQuantity = 0;
    notifyListeners();
  }

  Future<MessageModel?> bookProducts(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    try {
      _messageModel = await ProductService.bookProducts(payload);
      log('Book products payload: ${payload.toString()}');
    } catch (e) {
      log('Error booking products: ${e.toString()}');
    }
    setState(ViewState.idle);
    notifyListeners();
    return _messageModel;
  }

  void updateMarketData(Map<String, dynamic> data) {
    _marketData = data;
    final symbol = data['symbol'];
    final bid = data['bid']?.toDouble();

    if (symbol != null && bid != null) {
      if (symbol.toString().toLowerCase().contains('gold')) {
        _goldSpotRate = bid;
      }

      if (_marketModel != null) {
        _marketModel!.updateBid(symbol.toString(), bid);
      }
    }

    notifyListeners();
  }

  void getSpotRate() async {
    _goldSpotRate = await ProductService.getSpotRate();
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

  Future<void> getRealtimePrices() async {
    _marketPriceState = ViewState.loading;
    notifyListeners();

    _marketData = await ProductService.initializeSocketConnection();

    ProductService.marketDataStream.listen((data) {
      _marketData = data;

      notifyListeners();
    });

    _marketPriceState = ViewState.idle;
    notifyListeners();
  }

  bool _fetchInProgress = false;

  Future<void> fetchProducts(
      [String? adminId, String? categoryId, String pageIndex = "0"]) async {
    if (_fetchInProgress) {
      log('Fetch already in progress, skipping duplicate request');
      return;
    }

    _fetchInProgress = true;

    if (pageIndex == "0") {
      setState(ViewState.loading);
      _productList.clear();
      hasMoreData = true;
    } else {
      setState(ViewState.loadingMore);
    }

    isLoading = true;

    try {
      // Use the newly-structured fetchProducts method that handles the 
      // categoryId, adminId, and userSpotRateId selection logic
      final productsData = await ProductService.fetchProducts(
        adminId ?? _adminId,
        categoryId ?? _categoryId
      );

      log('API returned ${productsData.length} in-stock products');

      if (pageIndex == "0") {
        _productList.clear();
      }

      for (var item in productsData) {
        try {
          final product = Product.fromJson(item);
          _productList.add(product);
        } catch (e) {
          log('Error parsing product: ${e.toString()}');
        }
      }

      _productModel = ProductModel(
        success: _productList.isNotEmpty,
        data: List.from(_productList),
        page: Page(
            currentPage: int.parse(pageIndex),
            totalPage: productsData.isNotEmpty ? 2 : 1),
      );

      hasMoreData =
          _productModel!.page!.currentPage < _productModel!.page!.totalPage;
    } catch (e) {
      log('Error fetching products: ${e.toString()}');
      hasMoreData = false;
    } finally {
      setState(ViewState.idle);
      isLoading = false;
      _fetchInProgress = false;
      notifyListeners();
    }
  }

//   void clearQuantities() {
//   // Method 1: If you store quantities in a separate map
//   if (_productQuantities != null) {
//     _productQuantities.clear();
//   }
  
//   // Method 2: If quantities are stored in product objects
//   for (var product in productList) {
//     product.quantity = 0; // or null, depending on your model structure
//   }
  
//   // Ensure UI is updated
//   notifyListeners();
  
//   // Log confirmation
//   dev.log("Product quantities cleared successfully");
// }

// // Alternatively, if you're storing selected products in a separate list
// void clearSelectedProducts() {
//   selectedProducts.clear();
//   notifyListeners();
//   dev.log("Selected products cleared");
// }

  void setTotalQuantity(num quantity) {
  _totalQuantity = quantity;
  notifyListeners();
}

  void clearProducts() {
  _productList.clear();
  hasMoreData = true;
  _fetchInProgress = false;
  setState(ViewState.idle);
  notifyListeners();
}
  
  // Method to refresh user status and products
  Future<void> refreshUserStatus() async {
    await _initializeIds();
    await fetchProducts();
  }
}