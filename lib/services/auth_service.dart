import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up with Role and extra details
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? matricNumber,
    String? phoneNumber,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Committee members require approval, students don't
        bool isApproved = role != 'committee'; 

        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
          matricNumber: matricNumber,
          phoneNumber: phoneNumber,
          isApproved: isApproved,
          joinDate: DateTime.now(),
        );

        // 2. Store additional data in Firestore
        await _db.collection('users').doc(user.uid).set(newUser.toMap());
        return null; // Success
      }
      return "Registration failed. User is null.";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel? userData = await getUserData(user.uid);
        if (userData != null) {
          if (!userData.isApproved) {
            await _auth.signOut();
            return {'user': null, 'error': 'Your account is pending approval by an admin.'};
          }
          return {'user': user, 'userData': userData, 'error': null};
        }
      }
      return {'user': null, 'error': 'User data not found.'};
    } on FirebaseAuthException catch (e) {
      return {'user': null, 'error': e.message};
    } catch (e) {
      return {'user': null, 'error': e.toString()};
    }
  }

  // Get User Data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update Profile
  Future<bool> updateProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).update(user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Admin: Approve/Reject Committee Member
  Future<void> setApprovalStatus(String uid, bool status) async {
    await _db.collection('users').doc(uid).update({'isApproved': status});
  }

  // Admin: Get pending approvals
  Stream<List<UserModel>> getPendingApprovals() {
    return _db.collection('users')
        .where('role', isEqualTo: 'committee')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  User? get currentUser => _auth.currentUser;

  Future<void> logout() async {
    await _auth.signOut();
  }
}
