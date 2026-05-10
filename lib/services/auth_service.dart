import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isAnonymousUser(User? user) {
    if (user == null) return true;
    final email = user.email?.trim() ?? '';
    return email.isEmpty;
  }

  String? _captureAnonymousUid() {
    final user = _client.auth.currentUser;
    if (_isAnonymousUser(user)) {
      return user?.id;
    }
    return null;
  }

  Future<void> _mergeAnonymousDataIfNeeded({
    required String? oldAnonymousUid,
    required String? newUid,
  }) async {
    if (oldAnonymousUid == null || newUid == null || oldAnonymousUid == newUid) {
      return;
    }

    await _client.rpc('merge_anonymous_data', params: {
      'old_id': oldAnonymousUid,
      'new_id': newUid,
    });
  }

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Current authenticated user
  User? get currentUser => _client.auth.currentUser;

  // Sign in with Email and Password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final oldAnonymousUid = _captureAnonymousUid();

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final newUid = response.user?.id ?? _client.auth.currentUser?.id;
      await _mergeAnonymousDataIfNeeded(
        oldAnonymousUid: oldAnonymousUid,
        newUid: newUid,
      );

      return response;
    } catch (e) {
      debugPrint("Email sign-in error: $e");
      rethrow;
    }
  }

  // Sign up with Email and Password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final oldAnonymousUid = _captureAnonymousUid();

      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final newUid = response.user?.id ?? _client.auth.currentUser?.id;
      await _mergeAnonymousDataIfNeeded(
        oldAnonymousUid: oldAnonymousUid,
        newUid: newUid,
      );

      return response;
    } catch (e) {
      debugPrint("Email sign-up error: $e");
      rethrow;
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final oldAnonymousUid = _captureAnonymousUid();

      // For web, clientId must be specified in GoogleSignIn initialization or config.
      // On Android/iOS, it is automatically resolved from google-services.json/Info.plist if configured.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In was cancelled by user.';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Google Sign-In failed: No ID Token found.';
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final newUid = response.user?.id ?? _client.auth.currentUser?.id;
      await _mergeAnonymousDataIfNeeded(
        oldAnonymousUid: oldAnonymousUid,
        newUid: newUid,
      );

      return response;
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      rethrow;
    }
  }

  // Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    try {
      final oldAnonymousUid = _captureAnonymousUid();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw 'Apple Sign-In failed: No Identity Token found.';
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      final newUid = response.user?.id ?? _client.auth.currentUser?.id;
      await _mergeAnonymousDataIfNeeded(
        oldAnonymousUid: oldAnonymousUid,
        newUid: newUid,
      );

      return response;
    } catch (e) {
      debugPrint("Apple sign-in error: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint("Sign-out error: $e");
      rethrow;
    }
  }
  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _client.rpc('delete_user_account');
      await signOut();
    } catch (e) {
      debugPrint("Delete account error: $e");
      rethrow;
    }
  }
}
