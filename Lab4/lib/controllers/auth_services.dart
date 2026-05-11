import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<void>? _googleInitFuture;

  Future<void> _initializeGoogleSignIn() {
    _googleInitFuture ??= GoogleSignIn.instance.initialize();
    return _googleInitFuture!;
  }

  Future<String> createAccountWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return 'Account Created';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not create account';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return 'Login Successful';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not login';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _initializeGoogleSignIn();
    await _googleSignIn.signOut();
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<String> continueWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      if (!_googleSignIn.supportsAuthenticate()) {
        return 'Google Sign-In is not supported on this platform';
      }

      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;

      if (auth.idToken == null) {
        return 'Google Sign-In did not return an ID token';
      }

      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      await _auth.signInWithCredential(credential);
      return 'Google Login Successful';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google login failed';
    } on GoogleSignInException catch (e) {
      return e.description ?? e.code.name;
    } catch (e) {
      return e.toString();
    }
  }
}
