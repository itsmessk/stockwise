import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create a new user document in Firestore
      await _createUserDocument(result.user!);
      
      return result;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      // Check if user document already exists
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        // Create new user document with default values
        UserModel newUser = UserModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          favoriteLocations: [],
          preferences: UserPreferences().toJson(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
      }
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get user data from Firestore
  Future<UserModel> getUserData() async {
    try {
      User? user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        // If document doesn't exist, create it
        await _createUserDocument(user);
        
        // Get the newly created document
        DocumentSnapshot newDoc = await _firestore.collection('users').doc(user.uid).get();
        return UserModel.fromJson(newDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(UserModel userData) async {
    try {
      User? user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      await _firestore.collection('users').doc(user.uid).update(userData.toJson());
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Add a location to favorites
  Future<void> addFavoriteLocation(String location) async {
    try {
      User? user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      await _firestore.collection('users').doc(user.uid).update({
        'favoriteLocations': FieldValue.arrayUnion([location]),
      });
    } catch (e) {
      throw Exception('Failed to add favorite location: $e');
    }
  }

  // Remove a location from favorites
  Future<void> removeFavoriteLocation(String location) async {
    try {
      User? user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      await _firestore.collection('users').doc(user.uid).update({
        'favoriteLocations': FieldValue.arrayRemove([location]),
      });
    } catch (e) {
      throw Exception('Failed to remove favorite location: $e');
    }
  }
}
