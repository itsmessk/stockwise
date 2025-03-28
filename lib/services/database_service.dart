import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/weather_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user document reference
  DocumentReference get _userDoc {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }
    return _firestore.collection('users').doc(user.uid);
  }

  // Get user data
  Future<UserModel> getUserData() async {
    try {
      final doc = await _userDoc.get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('User document does not exist');
      }
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel userData) async {
    try {
      await _userDoc.update(userData.toJson());
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      await _userDoc.update({
        'preferences': preferences.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  // Add a location to favorites
  Future<void> addFavoriteLocation(String location) async {
    try {
      await _userDoc.update({
        'favoriteLocations': FieldValue.arrayUnion([location]),
      });
    } catch (e) {
      throw Exception('Failed to add favorite location: $e');
    }
  }

  // Remove a location from favorites
  Future<void> removeFavoriteLocation(String location) async {
    try {
      await _userDoc.update({
        'favoriteLocations': FieldValue.arrayRemove([location]),
      });
    } catch (e) {
      throw Exception('Failed to remove favorite location: $e');
    }
  }

  // Get favorite locations
  Future<List<String>> getFavoriteLocations() async {
    try {
      final doc = await _userDoc.get();
      
      if (doc.exists) {
        final userData = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        return userData.favoriteLocations;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get favorite locations: $e');
    }
  }

  // Save weather data to history
  Future<void> saveWeatherToHistory(Weather weather) async {
    try {
      await _userDoc.collection('weatherHistory').add({
        'location': weather.location,
        'country': weather.country,
        'temperature': weather.temperature,
        'condition': weather.condition,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save weather to history: $e');
    }
  }

  // Get weather history
  Future<List<Map<String, dynamic>>> getWeatherHistory() async {
    try {
      final snapshot = await _userDoc
          .collection('weatherHistory')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get weather history: $e');
    }
  }

  // Clear weather history
  Future<void> clearWeatherHistory() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _userDoc.collection('weatherHistory').get();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear weather history: $e');
    }
  }
}
