// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:swiss_gold/core/models/message.dart';
// import 'package:swiss_gold/core/models/wishlist_model.dart';
// import 'package:swiss_gold/core/services/local_storage.dart';
// import 'package:swiss_gold/core/services/secrete_key.dart';
// import 'package:swiss_gold/core/utils/endpoint.dart';

// class WishlistService {
//   static final client = http.Client();
//   // static Future<WishlistModel?> getWishlist() async {
//   //   try {
//   //     final id = await LocalStorage.getString('userId');

//   //     final url = getWishlistUrl.replaceFirst('{userId}', id.toString());
//   //     var response = await client.get(
//   //       Uri.parse(url),
//   //       headers: {
//   //         'X-Secret-Key': secreteKey,
//   //         'Content-Type': 'application/json'
//   //       }, // Encoding payload to JSON
//   //     );

//   //     if (response.statusCode == 200) {
//   //       Map<String, dynamic> responseData = jsonDecode(response.body);
//   //       // log(responseData.toString());
//   //       return WishlistModel.fromJson(responseData);
//   //     } else {
//   //       // Map<String, dynamic> responseData = jsonDecode(response.body);
//   //       // log(responseData.toString());
//   //       return null;
//   //     }
//   //   } catch (e) {
//   //     // log(e.toString());
//   //     return null;
//   //   }
//   // }

//   static Future<MessageModel?> addToWishlist(
//       Map<String, dynamic> payload) async {
//     try {
//       final id = await LocalStorage.getString('userId');

//       final url = addToWishlistUrl
//           .replaceFirst('{userId}', id.toString())
//           .replaceFirst('{pId}', payload['pId']);
//       var response = await client.patch(
//         Uri.parse(url),
//         headers: {
//           'X-Secret-Key': secreteKey,
//           'Content-Type': 'application/json'
//         }, // Encoding payload to JSON
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         return MessageModel.fromJson(responseData);
//       } else {
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         return MessageModel.fromJson(responseData);
//       }
//     } catch (e) {
//       // log(e.toString());
//       return null;
//     }
//   }

//   static Future<MessageModel?> deleteFromWishlist(
//       Map<String, dynamic> payload) async {
//     try {
//       final id = await LocalStorage.getString('userId');

//       final url = deleteFromWishlistUrl
//           .replaceFirst('{userId}', id.toString())
//           .replaceFirst('{pId}', payload['pId']);
//       var response = await client.delete(Uri.parse(url),
//           headers: {
//             'X-Secret-Key': secreteKey,
//             'Content-Type': 'application/json'
//           }, // Encoding payload to JSON
//           body: jsonEncode(payload));

//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         return MessageModel.fromJson(responseData);
//       } else {
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         return MessageModel.fromJson(responseData);
//       }
//     } catch (e) {
//       // log(e.toString());
//       return null;
//     }
//   }
// }
