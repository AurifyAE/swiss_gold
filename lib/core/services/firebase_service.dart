import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Saves the user's FCM token to Firebase Realtime Database
  Future<void> saveUserFcmToken(String userId, String token) async {
    try {
      // Reference to the user's FCM token in the database
      final userTokenRef = _database.child('users/$userId/fcmToken');
      
      // Save the token with a timestamp
      await userTokenRef.set({
        'token': token,
        'tokenUpdatedAt': ServerValue.timestamp,
      });
      
      log('FCM token successfully saved to Firebase Realtime Database');
    } catch (e) {
      log('Error saving FCM token to Firebase: $e');
      // You might want to handle the error or rethrow it
      rethrow;
    }
  }
  
  /// Gets the user's FCM token from Firebase Realtime Database
  Future<String?> getUserFcmToken(String userId) async {
    try {
      final DataSnapshot snapshot = 
          await _database.child('users/$userId/fcmToken/token').get();
      
      if (snapshot.exists) {
        return snapshot.value as String?;
      }
      return null;
    } catch (e) {
      log('Error getting FCM token from Firebase: $e');
      return null;
    }
  }
}