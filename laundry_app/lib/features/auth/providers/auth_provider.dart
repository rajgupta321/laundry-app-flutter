import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Main Auth Provider (State Notifier)
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(FirebaseAuth.instance.currentUser);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  /// sendOtp now supports auto OTP callback
  Future<void> sendOtp(
    String phoneNumber, {
    Function(String otp)? onOtp, // callback for auto OTP
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 30),

      // Auto verification (OTP detected automatically)
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        state = _auth.currentUser;

        // Auto OTP detected → trigger callback
        if (onOtp != null && credential.smsCode != null) {
          onOtp(credential.smsCode!);
        }
      },

      // Verification failed
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },

      // OTP sent
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },

      // Timeout
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> resendOtp(String phoneNumber) async {
    await sendOtp(phoneNumber);
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) return false;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      state = _auth.currentUser;
      return true;
    } catch (e) {
      print("OTP verification failed: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }
}

// StreamProvider to listen to auth changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
