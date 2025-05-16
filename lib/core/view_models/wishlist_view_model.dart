// import 'package:swiss_gold/core/models/message.dart';
// import 'package:swiss_gold/core/models/wishlist_model.dart';
// import 'package:swiss_gold/core/services/local_storage.dart';
// import 'package:swiss_gold/core/services/wishlist_service.dart';
// import 'package:swiss_gold/core/utils/enum/view_state.dart';
// import 'package:swiss_gold/core/view_models/base_model.dart';

// class WishlistViewModel extends BaseModel {
//   WishlistModel? _wishlistModel;
//   WishlistModel? get wishlistModel => _wishlistModel;

//   bool? _isGuest;
//   bool? get isGuest => _isGuest;

//   final List<WishItem> _wishItemList = [];
//   List<WishItem> get wishlist => _wishItemList;

//   MessageModel? _messageModel;
//   MessageModel? get messageModel => _messageModel;

//   // Future<void> getWishlist() async {
//   //   setState(ViewState.loading);
//   //   _wishlistModel = await WishlistService.getWishlist();
//   //   _wishItemList.clear();

//   //   if (_wishlistModel != null) {
//   //     for (var wishItem in wishlistModel!.data) {
//   //       for (var item in wishItem.items) {
//   //         _wishItemList.add(item);
//   //       }
//   //     }
//   //   }

//   //   setState(ViewState.idle);
//   //   notifyListeners();
//   // }

//   Future<MessageModel?> deleteFromWishlist(Map<String, dynamic> payload) async {
//     setState(ViewState.loading);
//     _messageModel = await WishlistService.deleteFromWishlist(payload);
//     setState(ViewState.idle);
//     notifyListeners();
//     return _messageModel;
//   }

//   checkGuestMode() async {
//     _isGuest = await LocalStorage.getBool('isGuest');
//     notifyListeners();
//   }

//   Future<MessageModel?> addToWishlist(Map<String, dynamic> payload) async {
//     setState(ViewState.loading);
//     _messageModel = await WishlistService.addToWishlist(payload);
//     setState(ViewState.idle);
//     notifyListeners();
//     return _messageModel;
//   }
// }
