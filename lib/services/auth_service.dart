import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String getAuthErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  return 'Something went wrong. Please try again.';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    UserCredential userCredential =
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential =
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();

    return doc.data()?['role'] ?? 'student';
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}