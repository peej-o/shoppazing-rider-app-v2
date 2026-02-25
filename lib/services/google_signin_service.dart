import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In process...');

      // Simple sign in - no Firebase needed
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return GoogleSignInResult(
          success: false,
          error: 'Sign in was cancelled by user',
        );
      }

      // Get basic user info - no authentication needed for basic profile
      final userData = GoogleUserData(
        id: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ?? '',
        firstName: _extractFirstName(googleUser.displayName ?? ''),
        lastName: _extractLastName(googleUser.displayName ?? ''),
        photoUrl: await googleUser.photoUrl ?? '',
        idToken: '', // Optional muna
        accessToken: '', // Optional muna
      );

      return GoogleSignInResult(success: true, userData: userData);
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return GoogleSignInResult(
        success: false,
        error: 'Sign in failed: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
  }

  String _extractFirstName(String displayName) {
    if (displayName.isEmpty) return '';
    final parts = displayName.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  String _extractLastName(String displayName) {
    if (displayName.isEmpty) return '';
    final parts = displayName.split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }
    return '';
  }
}

class GoogleSignInResult {
  final bool success;
  final GoogleUserData? userData;
  final String? error;

  GoogleSignInResult({required this.success, this.userData, this.error});
}

class GoogleUserData {
  final String id;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;
  final String photoUrl;
  final String idToken;
  final String accessToken;

  GoogleUserData({
    required this.id,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.idToken,
    required this.accessToken,
  });
}
