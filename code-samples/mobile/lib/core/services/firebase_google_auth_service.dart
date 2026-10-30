// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Project imports:
import 'logger_service.dart';

enum FirebaseGoogleAuthError { cancelled, failed, missingFirebaseIdToken }

class FirebaseGoogleAuthException implements Exception {
  final FirebaseGoogleAuthError error;
  final Object? cause;

  const FirebaseGoogleAuthException(this.error, {this.cause});
}

/// Owns the Firebase/Google provider flow and returns only Firebase ID tokens.
class FirebaseGoogleAuthService {
  FirebaseGoogleAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize();
  }

  /// Completes the interactive Google flow and returns a Firebase ID token.
  ///
  /// The Google token is used only to authenticate with Firebase. It is never
  /// returned to callers or sent to the backend.
  Future<String> signInAndGetFirebaseIdToken() async {
    await _ensureInitialized();

    try {
      final googleAccount = await _googleSignIn.authenticate();
      final googleIdToken = googleAccount.authentication.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw const FirebaseGoogleAuthException(
          FirebaseGoogleAuthError.missingFirebaseIdToken,
        );
      }
      final credential = await _firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: googleIdToken),
      );

      final firebaseIdToken = await credential.user?.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw const FirebaseGoogleAuthException(
          FirebaseGoogleAuthError.missingFirebaseIdToken,
        );
      }

      return firebaseIdToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw FirebaseGoogleAuthException(
          FirebaseGoogleAuthError.cancelled,
          cause: e,
        );
      }

      throw FirebaseGoogleAuthException(
        FirebaseGoogleAuthError.failed,
        cause: e,
      );
    } catch (e) {
      throw FirebaseGoogleAuthException(
        FirebaseGoogleAuthError.failed,
        cause: e,
      );
    }
  }

  /// Signs out of provider SDKs without blocking local app-session cleanup.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e, st) {
      LoggerService.warning(
        'FirebaseGoogleAuthService: Firebase sign out failed: ${e.runtimeType}',
      );
      LoggerService.debug(st.toString());
    }

    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (e, st) {
      LoggerService.warning(
        'FirebaseGoogleAuthService: Google sign out failed: ${e.runtimeType}',
      );
      LoggerService.debug(st.toString());
    }
  }
}
