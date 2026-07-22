import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pantrysaver/models/user_profile.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth get auth {
    _auth ??= _createAuth();
    return _auth!;
  }

  FirebaseFirestore get firestore {
    _firestore ??= _createFirestore();
    return _firestore!;
  }

  FirebaseAuth _createAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      throw Exception('Firebase Authentication is unavailable. Please ensure Firebase is initialized.');
    }
  }

  FirebaseFirestore _createFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      throw Exception('Firebase Firestore is unavailable. Please ensure Firebase is initialized.');
    }
  }

  User? get currentUser {
    try {
      return auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final profile = UserProfile(
        uid: credential.user!.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        monthlyBudget: 0,
        createdAt: DateTime.now(),
      );

      await firestore.collection('users').doc(credential.user!.uid).set(profile.toMap(), SetOptions(merge: true));
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication failed.');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Could not write to Firestore. Check your rules and Firebase config.');
    } catch (e) {
      throw Exception('Unexpected error. Check your Firebase configuration.');
    }
  }

  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      return await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign-in failed.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed.');
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final snapshot = await firestore.collection('users').doc(uid).get();
      if (!snapshot.exists) return null;
      return UserProfile.fromMap(snapshot.data()!);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'unavailable') {
        return null;
      }
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await firestore.collection('users').doc(profile.uid).update({
      'fullName': profile.fullName,
      'monthlyBudget': profile.monthlyBudget,
      'notificationsEnabled': profile.notificationsEnabled,
    });
  }
}
