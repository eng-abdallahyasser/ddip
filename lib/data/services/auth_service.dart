import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends GetxService {
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Configure GoogleSignIn; on web, pass the web client ID if provided
    _googleSignIn = kIsWeb && AppConfig.googleWebClientId.isNotEmpty
        ? GoogleSignIn(clientId: AppConfig.googleWebClientId)
        : GoogleSignIn();
  }

  Future<bool> signInWithGoogle() async {
    try {
      final auth = FirebaseAuth.instance;
      if (kIsWeb) {
        // On Web prefer popup via FirebaseAuth
        final provider = GoogleAuthProvider();
        await auth.signInWithPopup(provider);
        return auth.currentUser != null;
      } else {
        final account = await _googleSignIn.signIn();
        if (account == null) return false; // cancelled
        final googleAuth = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        await auth.signInWithCredential(credential);
        return auth.currentUser != null;
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> signInWithEmail({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return FirebaseAuth.instance.currentUser != null;
    } on FirebaseAuthException catch (_) {
      return false;
    }
  }

  Future<bool> registerWithEmail({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      return FirebaseAuth.instance.currentUser != null;
    } on FirebaseAuthException catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      }
    } catch (_) {}
  }
}
