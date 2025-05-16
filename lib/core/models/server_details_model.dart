// import 'dart:convert';

// ServerModel serverModelFromMap(String str) =>
//     ServerModel.fromMap(json.decode(str));

// String serverModelToMap(ServerModel data) => json.encode(data.toMap());

// class ServerModel {
//   final bool success;
//   final Info info;
//   final String message;

//   ServerModel({
//     required this.success,
//     required this.info,
//     required this.message,
//   });

//   ServerModel copyWith({
//     bool? success,
//     Info? info,
//     String? message,
//   }) =>
//       ServerModel(
//         success: success ?? this.success,
//         info: info ?? this.info,
//         message: message ?? this.message,
//       );

//   factory ServerModel.fromMap(Map<String, dynamic> json) => ServerModel(
//         success: json["success"],
//         info: Info.fromMap(json["info"]),
//         message: json["message"],
//       );

//   Map<String, dynamic> toMap() => {
//         "success": success,
//         "info": info.toMap(),
//         "message": message,
//       };
// }

// class Info {
//   final String serverUrl;
//   final String serverName;

//   Info({
//     required this.serverUrl,
//     required this.serverName,
//   });

//   Info copyWith({
//     String? serverUrl,
//     String? serverName,
//   }) =>
//       Info(
//         serverUrl: serverUrl ?? this.serverUrl,
//         serverName: serverName ?? this.serverName,
//       );

//   factory Info.fromMap(Map<String, dynamic> json) => Info(
//         serverUrl: json["serverURL"],
//         serverName: json["serverName"],
//       );

//   Map<String, dynamic> toMap() => {
//         "serverURL": serverUrl,
//         "serverName": serverName,
//       };
// }
