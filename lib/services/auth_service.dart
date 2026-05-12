import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up with Role
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create a new document for the user in Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
        );
        await _db.collection('users').doc(user.uid).set(newUser.toMap());
      }
      return user;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Sign In Error: $e");
      return null;
    }
  }

  // Get User Data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Get User Data Error: $e");
      return null;
    }
  }

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}