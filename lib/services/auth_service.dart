import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stockwise/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Create AppUser object from Firebase User
  AppUser? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser.fromFirebaseUser(user);
  }

  // Auth state changes stream
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Get current user
  AppUser? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update email
  Future<void> updateEmail(String email) async {
    try {
      await _auth.currentUser?.updateEmail(email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update password
  Future<void> updatePassword(String password) async {
    try {
      await _auth.currentUser?.updatePassword(password);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Re-authenticate user
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    try {
      return await _auth.currentUser!.reauthenticateWithCredential(credential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'invalid-email':
          return Exception('The email address is not valid.');
        case 'user-disabled':
          return Exception('This user has been disabled.');
        case 'email-already-in-use':
          return Exception('The email address is already in use.');
        case 'operation-not-allowed':
          return Exception('Email/password accounts are not enabled.');
        case 'weak-password':
          return Exception('The password is too weak.');
        case 'requires-recent-login':
          return Exception('This operation requires recent authentication. Please log in again.');
        default:
          return Exception('Authentication error: ${e.message}');
      }
    }
    return Exception('Authentication error: $e');
  }
}
